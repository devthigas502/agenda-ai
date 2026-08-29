import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="theme"
export default class extends Controller {
  static targets = ["darkIcon", "lightIcon", "systemIcon", "toggleBtn", "statusText", "optionBtn"]
  static values = {
    current: { type: String, default: "system" }
  }

  connect() {
    this.mediaQuery = window.matchMedia("(prefers-color-scheme: dark)")
    this.handleSystemChange = this.handleSystemChange.bind(this)
    this.handleThemeChangedEvent = this.handleThemeChangedEvent.bind(this)

    this.mediaQuery.addEventListener("change", this.handleSystemChange)
    window.addEventListener("theme:changed", this.handleThemeChangedEvent)

    const savedTheme = localStorage.getItem("theme") || "system"
    this.applyTheme(savedTheme, false)
  }

  disconnect() {
    if (this.mediaQuery) {
      this.mediaQuery.removeEventListener("change", this.handleSystemChange)
    }
    window.removeEventListener("theme:changed", this.handleThemeChangedEvent)
  }

  toggle() {
    const isDark = document.documentElement.classList.contains("dark")
    const nextTheme = isDark ? "light" : "dark"
    this.setTheme(nextTheme)
  }

  setLight() {
    this.setTheme("light")
  }

  setDark() {
    this.setTheme("dark")
  }

  setSystem() {
    this.setTheme("system")
  }

  selectTheme(event) {
    const theme = event.currentTarget.dataset.themeValue || event.params.theme
    if (theme) {
      this.setTheme(theme)
    }
  }

  setTheme(theme) {
    localStorage.setItem("theme", theme)
    this.applyTheme(theme, true)
  }

  applyTheme(theme, dispatch = true) {
    this.currentValue = theme
    const isSystemDark = this.mediaQuery ? this.mediaQuery.matches : false
    const shouldBeDark = theme === "dark" || (theme === "system" && isSystemDark)

    if (shouldBeDark) {
      document.documentElement.classList.add("dark")
      document.documentElement.classList.remove("light")
      document.documentElement.setAttribute("data-theme", "dark")
      document.documentElement.style.colorScheme = "dark"
    } else {
      document.documentElement.classList.remove("dark")
      document.documentElement.classList.add("light")
      document.documentElement.setAttribute("data-theme", "light")
      document.documentElement.style.colorScheme = "light"
    }

    this.updateUI(theme, shouldBeDark)

    if (dispatch) {
      window.dispatchEvent(
        new CustomEvent("theme:changed", {
          detail: { theme, isDark: shouldBeDark }
        })
      )
    }
  }

  handleThemeChangedEvent(e) {
    if (e.detail) {
      this.updateUI(e.detail.theme, e.detail.isDark)
    }
  }

  handleSystemChange(e) {
    const savedTheme = localStorage.getItem("theme")
    if (!savedTheme || savedTheme === "system") {
      this.applyTheme("system", true)
    }
  }

  updateUI(theme, isDark) {
    // Update icons visibility if targets are defined
    if (this.hasDarkIconTarget) {
      this.darkIconTarget.classList.toggle("hidden", !isDark)
    }
    if (this.hasLightIconTarget) {
      this.lightIconTarget.classList.toggle("hidden", isDark)
    }

    // If toggle button has aria-label or title
    if (this.hasToggleBtnTarget) {
      const label = isDark ? "Mudar para modo claro" : "Mudar para modo escuro"
      this.toggleBtnTarget.setAttribute("aria-label", label)
      this.toggleBtnTarget.setAttribute("title", label)
    }

    // If status text exists
    if (this.hasStatusTextTarget) {
      this.statusTextTarget.textContent = isDark ? "Escuro" : "Claro"
    }

    // If segmented option buttons exist
    if (this.hasOptionBtnTargets) {
      this.optionBtnTargets.forEach((btn) => {
        const btnTheme = btn.dataset.themeValue
        const isActive = btnTheme === theme
        btn.classList.toggle("bg-white", isActive)
        btn.classList.toggle("dark:bg-slate-700", isActive)
        btn.classList.toggle("text-indigo-600", isActive)
        btn.classList.toggle("dark:text-indigo-400", isActive)
        btn.classList.toggle("shadow-xs", isActive)
        btn.classList.toggle("font-semibold", isActive)
      })
    }
  }
}

