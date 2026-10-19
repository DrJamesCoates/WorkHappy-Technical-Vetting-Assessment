const form = document.querySelector<HTMLFormElement>("#filters");
const button = document.querySelector<HTMLButtonElement>("#export-button");
const message = document.querySelector<HTMLElement>("#export-message");

async function exportCsv(): Promise<void> {
  if (!form || !button || !message) return;

  const params = new URLSearchParams();
  for (const name of ["from", "to", "status"]) {
    const value = (form.elements.namedItem(name) as HTMLInputElement | null)?.value;
    if (value) params.set(name, value);
  }

  button.disabled = true;
  message.textContent = "Preparing export...";
  try {
    const response = await fetch(`${button.dataset.url}?${params}`, { credentials: "same-origin" });

    if (response.status === 422) {
      const { errors } = (await response.json()) as { errors: string[] };
      message.textContent = errors.join(". ");
      return;
    }
    if (!response.ok) throw new Error(`HTTP ${response.status}`);

    const link = document.createElement("a");
    link.href = URL.createObjectURL(await response.blob());
    link.download = /filename=([^;]+)/.exec(response.headers.get("Content-Disposition") ?? "")?.[1] ?? "assessments.csv";
    link.click();
    URL.revokeObjectURL(link.href);
    message.textContent = "Export downloaded.";
  } catch {
    message.textContent = "Export failed. Please try again.";
  } finally {
    button.disabled = false;
  }
}

button?.addEventListener("click", exportCsv);
