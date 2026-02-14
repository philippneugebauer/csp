// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "bootstrap"

const setupTooltips = () => {
  const Tooltip = window.bootstrap?.Tooltip
  if (!Tooltip) return

  document.querySelectorAll('[data-bs-toggle="tooltip"]').forEach((el) => {
    Tooltip.getOrCreateInstance(el)
  })
}

const disposeTooltips = () => {
  const Tooltip = window.bootstrap?.Tooltip
  if (!Tooltip) return

  document.querySelectorAll('[data-bs-toggle="tooltip"]').forEach((el) => {
    const instance = Tooltip.getInstance(el)
    instance?.dispose()
  })
}

document.addEventListener("turbo:load", setupTooltips)
document.addEventListener("turbo:before-cache", disposeTooltips)
