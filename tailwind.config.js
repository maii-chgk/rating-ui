module.exports = {
  content: [
    './app/views/**/*.html.erb',
    './app/views/**/*.html',
    './app/helpers/**/*.rb',
    './app/components/**/*.{erb,html}',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js'
  ],
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
  ],
  theme: {
    fontFamily: {
      sans: "Inter var, ui-sans-serif, system-ui",
      serif: "Inter var, ui-sans-serif, system-ui"
    }
  },
  darkMode: 'media'
}
