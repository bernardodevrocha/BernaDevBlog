import bleach

# Whitelist for rendered HTML from markdown
ALLOWED_TAGS = [
    "p", "h1", "h2", "h3", "h4", "h5", "h6",
    "ul", "ol", "li", "blockquote", "pre", "code",
    "strong", "em", "del", "a", "img", "hr", "br",
    "table", "thead", "tbody", "tr", "th", "td",
]

ALLOWED_ATTRIBUTES = {
    "a": ["href", "title", "rel"],
    "img": ["src", "alt", "title"],
    "code": ["class"],
    "th": ["scope"],
    "td": ["colspan", "rowspan"],
}


def sanitize_html(raw_html: str) -> str:
    return bleach.clean(raw_html, tags=ALLOWED_TAGS, attributes=ALLOWED_ATTRIBUTES, strip=True)


def sanitize_text(text: str) -> str:
    return bleach.clean(text, tags=[], strip=True)
