settings.defaultSearchEngine = "d";
settings.enableEmojiInsertion = true;

api.unmap("<Ctrl-h>");

// edition
api.map("eu", ";U");
api.unmap(";U");
api.map("eU", ";u");
api.unmap(";u");

// find
api.unmap("t");
api.mapkey("<Space><Space>", "Find urls", function () {
  api.Front.openOmnibar({ type: "URLs" });
});
api.mapkey("<Space>f'", "Find marks", function () {
  api.Front.openOmnibar({ type: "VIMarks" });
});
api.mapkey("<Space>f:", "Find commands", function () {
  api.Front.openOmnibar({ type: "Commands" });
});
api.mapkey("<Space>fb", "Find bookmarks", function () {
  api.Front.openOmnibar({ type: "Bookmarks" });
});
api.mapkey("<Space>fe", "Find searchEngine", function () {
  api.Front.openOmnibar({ type: "SearchEngine" });
});
api.mapkey("<Space>fh", "Find History", function () {
  api.Front.openOmnibar({ type: "History" });
});
api.mapkey("<Space>fr", "Find recently closed", function () {
  api.Front.openOmnibar({ type: "RecentlyClosed" });
});
api.mapkey("<Space>ft", "Find tabs", function () {
  api.Front.openOmnibar({ type: "Tabs" });
});
api.mapkey("<Space>fu", "Find subURLs", function () {
  api.Front.openOmnibar({ type: "TabURLs" });
});
api.mapkey("<Space>fw", "Find windows", function () {
  api.Front.openOmnibar({ type: "Windows" });
});

// hints
api.map("F", "gf");
api.unmap("gf");
api.map("gf", "L");
api.unmap("L");

// marks
api.map("`", "m");

// navigation
api.map("J", "d");
api.unmap("d");
api.map("K", "e");
api.unmap("e");
api.map("H", "S");
api.unmap("S");
api.map("L", "D");
api.unmap("d");
api.map("[<Tab>", "E");
api.unmap("E");
api.map("]<Tab>", "R");
api.unmap("R");

// set theme
api.Hints.style(
  "font-family: sans-serif; font-size: 13px; border: solid 2px #373B41; color: #4FD6BE; background: initial; background-color: #1D1F21;",
);
api.Hints.style(
  "font-family: sans-serif; font-size: 13px; border: solid 2px #373B41 !important; padding: 1px !important; color: #FF966C !important; background: #1D1F21 !important;",
  "text",
);
api.Visual.style("cursor", "background-color: #FF966C;");

settings.theme = `
/* Edit these variables for easy theme making */
:root {
  /* Font */
  --font-family: 'CommitMono Nerd Font Mono', Arial, sans-serif;
  --font-size: 15px;
  --font-weight: normal;

  --fg: #C8D3F5;
  --bg: #282A2E;
  --bg-dark: #1D1F2188;
  --border: #373b41;
  --main-fg: #81A2BE;
  --accent-fg: #4FD6BE;
  --info-fg: #C099FF;
  --select: #585858;

  --cursor: #FF966C;
  /* Unused Alternate Colors */
  /* --cyan: #65BCFF; */
  /* --red: #FF757F; */
  /* --yellow: #FFC777; */
}

/* ---------- Generic ---------- */
.sk_theme {
background: var(--bg);
color: var(--fg);
  background-color: var(--bg);
  border-color: var(--border);
  font-family: var(--font);
  font-size: var(--font-size);
  font-weight: var(--font-weight);
}

input {
  font-family: var(--font);
  font-weight: var(--font-weight);
}

.sk_theme tbody {
  color: var(--fg);
}

.sk_theme input {
  color: var(--fg);
}

/* Hints */
#sk_hints .begin {
  color: var(--accent-fg) !important;
}

#sk_tabs .sk_tab {
  background: var(--bg-dark);
  border: 1px solid var(--border);
}

#sk_tabs .sk_tab_title {
  color: var(--fg);
}

#sk_tabs .sk_tab_url {
  color: var(--main-fg);
}

#sk_tabs .sk_tab_hint {
  background: var(--bg);
  border: 1px solid var(--border);
  color: var(--accent-fg);
}

.sk_theme #sk_frame {
  background: var(--bg);
  opacity: 0.2;
  color: var(--accent-fg);
}

/* ---------- Omnibar ---------- */
/* Uncomment this and use settings.omnibarPosition = 'bottom' for Pentadactyl/Tridactyl style bottom bar */
/* .sk_theme#sk_omnibar {
  width: 100%;
  left: 0;
} */

.sk_theme .title {
  color: var(--accent-fg);
}

.sk_theme .url {
  color: var(--main-fg);
}

.sk_theme .annotation {
  color: var(--accent-fg);
}

.sk_theme .omnibar_highlight {
  color: var(--accent-fg);
}

.sk_theme .omnibar_timestamp {
  color: var(--info-fg);
}

.sk_theme .omnibar_visitcount {
  color: var(--accent-fg);
}

.sk_theme #sk_omnibarSearchResult ul li:nth-child(odd) {
  background: var(--bg-dark);
}

.sk_theme #sk_omnibarSearchResult ul li.focused {
  background: var(--border);
}

.sk_theme #sk_omnibarSearchArea {
  border-top-color: var(--border);
  border-bottom-color: var(--border);
}

.sk_theme #sk_omnibarSearchArea input,
.sk_theme #sk_omnibarSearchArea span {
  font-size: var(--font-size);
}

.sk_theme .separator {
  color: var(--accent-fg);
}

/* ---------- Popup Notification Banner ---------- */
#sk_banner {
  font-family: var(--font);
  font-size: var(--font-size);
  font-weight: var(--font-weight);
  background: var(--bg);
  border-color: var(--border);
  color: var(--fg);
  opacity: 0.9;
}

/* ---------- Popup Keys ---------- */
#sk_keystroke {
  background-color: var(--bg);
}

.sk_theme kbd .candidates {
  color: var(--info-fg);
}

.sk_theme span.annotation {
  color: var(--accent-fg);
}

/* ---------- Popup Translation Bubble ---------- */
#sk_bubble {
  background-color: var(--bg) !important;
  color: var(--fg) !important;
  border-color: var(--border) !important;
}

#sk_bubble * {
  color: var(--fg) !important;
}

#sk_bubble div.sk_arrow div:nth-of-type(1) {
  border-top-color: var(--border) !important;
  border-bottom-color: var(--border) !important;
}

#sk_bubble div.sk_arrow div:nth-of-type(2) {
  border-top-color: var(--bg) !important;
  border-bottom-color: var(--bg) !important;
}

/* ---------- Search ---------- */
#sk_status,
#sk_find {
  font-size: var(--font-size);
  border-color: var(--border);
}

.sk_theme kbd {
  background: var(--bg-dark);
  border-color: var(--border);
  box-shadow: none;
  color: var(--fg);
}

.sk_theme .feature_name span {
  color: var(--main-fg);
}

/* ---------- ACE Editor ---------- */
#sk_editor {
  background: var(--bg-dark) !important;
}

.ace_dialog-bottom {
  border-top: 1px solid var(--bg) !important;
}

.ace-chrome .ace_print-margin,
.ace_gutter,
.ace_gutter-cell,
.ace_dialog {
  background: var(--bg) !important;
}

.ace-chrome {
  color: var(--fg) !important;
}

.ace_gutter,
.ace_dialog {
  color: var(--fg) !important;
}

.ace_cursor {
  color: var(--cursor) !important;
}

.normal-mode .ace_cursor {
  background-color: var(--cursor) !important;
  border: var(--fg) !important;
}

.ace_marker-layer .ace_selection {
  background: var(--select) !important;
}

.ace_editor,
.ace_dialog span,
.ace_dialog input {
  font-family: var(--font);
  font-size: var(--font-size);
  font-weight: var(--font-weight);
}
`;
// click `Save` button to make above settings to take effect.</ctrl-i></ctrl-y>
