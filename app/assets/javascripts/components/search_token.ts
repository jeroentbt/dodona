import { html, TemplateResult } from "lit";
import { customElement, property } from "lit/decorators.js";
import { ShadowlessLitElement } from "components/shadowless_lit_element";
import { FilterCollection, FilterCollectionElement, Label } from "components/filter_collection_element";

@customElement("dodona-search-token")
export class SearchToken extends FilterCollectionElement {
    @property()
    color: (l: Label) => string;

    render(): TemplateResult {
        return html`
            ${ this.getSelectedLabels().map( label => html`
                <div class="token accent-${this.color(label)}">
                    <span class="token-label">${label.name}</span>
                    <a href="#" class="close" tabindex="-1"  @click=${() => this.unSelect(label)}>×</a>
                </div>
            `)}
        `;
    }
}

@customElement("dodona-search-tokens")
export class SearchTokens extends ShadowlessLitElement {
    @property( { type: Array })
    filterCollections: Record<string, FilterCollection>;

    render(): TemplateResult {
        if (!this.filterCollections) {
            return html``;
        }

        return html`
            ${Object.values(this.filterCollections).map(c => html`
                <dodona-search-token
                    .labels=${c.data}
                    .color=${c.color}
                    .paramVal=${c.paramVal}
                    .param=${c.param}
                    .multi=${c.multi}
                >
                </dodona-search-token>
            `)}
        `;
    }
}

