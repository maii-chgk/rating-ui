module.exports = {
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/components/**/*.{erb,html}',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js'
  ],
  plugins: [
    require('@tailwindcss/forms'),
  ],
  theme: {
    fontFamily: {
      sans: "Inter var, ui-sans-serif, system-ui",
      serif: "Inter var, ui-sans-serif, system-ui"
    }
  }
}
