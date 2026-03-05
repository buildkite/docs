# Accessibility

Buildkite is committed to making its web application usable for everyone, including people who rely on assistive technologies, keyboard navigation, or adjusted visual settings. This page documents the accessibility features currently available across the Buildkite platform.

## Theme and display options

Buildkite offers three display theme options, accessible from the top global navigation bar. While these are primarily comfort and usability features rather than accessibility-specific accommodations, they can help users adjust the interface to suit their visual preferences:

- **Light**: the default Buildkite theme
- **Dark**: an experimental dark mode that inverts the interface colors
- **System**: automatically matches your operating system's light or dark preference

The theme selection persists across sessions. When set to **System**, Buildkite responds to changes in your operating system's display settings in real time.

> 📘 Experimental dark mode
> Dark mode is currently experimental and uses a CSS color inversion technique. Some visual elements may not be displayed perfectly in dark mode. Buildkite is working toward native dark mode support in newer interface components.

### Job log themes

The job log viewer offers an additional theme toggle, allowing you to switch between a default dark theme and a light theme for improved readability based on your preference.

## Keyboard navigation

The Buildkite web application supports keyboard navigation, largely through standard browser behavior. Some areas of the application have more intentional keyboard support than others.

### Skip navigation

Some layouts include a **Skip to main content** link that becomes visible when focused. This allows keyboard and screen reader users to bypass the navigation and jump directly to the page content.

### Focus indicators

Interactive elements display visible focus rings when navigated using the keyboard. Buildkite uses the `:focus-visible` CSS pseudo-class, so that focus indicators appear during keyboard navigation and don't interfere with mouse interactions. Coverage may vary across some custom components.

### Keyboard shortcuts

Several areas of the application support keyboard shortcuts:

- **Build page**: has dedicated keyboard shortcuts for navigating builds, jumping to failures, and searching steps. See [build page keyboard shortcuts](/docs/pipelines/build-page#keyboard-shortcuts) for the full list.
- **Job log search**: type `s` to focus the search input, and `Escape` to close it.
- **Dialogs**: type `Escape` to close any open dialog, and focus is trapped within the dialog while it is open.
- **Dropdowns and autocomplete**: arrow keys navigate options, `Enter` selects, and `Escape` closes.

### Interactive components

Custom interactive components such as dropdowns, combo boxes, tree views, and toggle switches all support keyboard operation, including arrow key navigation and enter/escape key handling.

## Screen reader support

Buildkite uses semantic HTML and ARIA attributes to support screen readers. The depth of support varies across the application—key components have intentional ARIA labeling, while others rely on browser and platform defaults.

### Semantic structure

- Pages use the `<main>` landmark element with an `id` anchor for skip navigation.
- The `lang="en"` attribute is set on the root `<html>` element.
- Navigation, headers, and content areas use semantic HTML elements in many areas.

### ARIA attributes

Key interface components include ARIA attributes to convey their purpose and state to assistive technologies:

- **Build status icons**: include `aria-label` attributes describing the current state, for example, **Build state: PASSED**.
- **Dialogs**: use `role="dialog"` with appropriate labeling.
- **Tree views**: in the build sidebar use `role="tree"` and `role="treeitem"` with `aria-expanded` state.
- **Combo boxes**: use `role="listbox"` and `role="option"` with `aria-selected` state.
- **Toggle switches**: use `role="switch"` with `aria-checked` and `aria-labelledby`.
- **Tab interfaces**: use `role="tablist"` for tabbed navigation.
- **Status updates**: use `role="status"` and `role="alert"` to announce changes to screen readers.
- **Decorative elements**: mark with `aria-hidden="true"` to prevent screen reader noise.

### Visually hidden content

Buildkite uses visually hidden text (hidden from the screen but available to screen readers) to provide additional context where the visual interface relies on icons or layout for meaning.

## Color and contrast

### Status indicators

Build and job status indicators use both color and distinct icon shapes to convey state. For example, a passed build uses a green checkmark, while a failed build uses a red cross. This means status information doesn't rely on color alone and remains accessible to color-blind users.

### Color token system

Buildkite uses a semantic color token system that maps status concepts (success, warning, error, neutral) to specific color palettes with defined foreground, background, and stroke values. This system enables consistent color usage across the application.

### Focus ring colors

Keyboard focus indicators use high-visibility colors (lime green and purple) that contrast with the surrounding interface elements.

## Typography and text scaling

- The base font size is set to 16px, matching the browser default.
- The browser view is configured with `width=device-width, initial-scale=1.0` without restricting user zoom, allowing browser-level text scaling and zoom to work as expected.
- Buildkite uses a defined typography hierarchy for headings and body text.

## Form accessibility

- Form inputs include associated `<label>` elements.
- Required fields are indicated with a **Required** text suffix.
- Related form controls are grouped using `<fieldset>` and `<legend>` elements where appropriate.

## Voice input and text-to-speech

The Buildkite web application doesn't include custom voice input or text-to-speech features. The application relies on operating system and browser-level assistive technologies for these capabilities. The ARIA attributes and semantic HTML described above support the correct functioning of these platform-level tools.

## Mobile accessibility

The Buildkite web application uses responsive design, adapting to different screen sizes and orientations. Standard browser accessibility features, including text scaling and screen reader support, function on mobile devices.

## Known limitations

While Buildkite continues to improve accessibility, there are some known limitations:

- Dark mode uses a CSS color inversion technique, which can occasionally affect color contrast ratios or cause visual artifacts in some components.
- High contrast mode (`prefers-contrast`) is not currently detected or supported with custom styles.
- Form error messages are not consistently associated with their inputs using `aria-describedby`, which may affect screen reader users in some forms.
- Not all dynamic content updates use `aria-live` regions, and therefore, some real-time updates may not be immediately announced by screen readers.
- There is no built-in font size adjustment feature in the Buildkite interface (browser zoom can be used instead).
- No keyboard shortcut reference or help panel is currently available.

## Feedback

If you encounter accessibility issues or have suggestions for improvement, contact the Buildkite support team at [support@buildkite.com](mailto:support@buildkite.com).
