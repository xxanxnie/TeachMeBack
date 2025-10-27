import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "list"]
  
  filter() {
    const q = (this.inputTarget.value || "").trim().toLowerCase()
    const items = this.listTarget.querySelectorAll("[data-search-item]")
    let visibleCount = 0
    
    items.forEach(el => {
      const text = el.innerText.toLowerCase()
      const isVisible = text.includes(q)
      el.style.display = isVisible ? "" : "none"
      if (isVisible) visibleCount++
    })
    
    // Update count badge
    const countBadge = document.getElementById("request-count")
    if (countBadge) {
      countBadge.textContent = visibleCount
    }
  }
}

