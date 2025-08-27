const setTheme = (theme: any) => {
    document.documentElement.style.setProperty('--color-primary', theme.primary)
    document.documentElement.style.setProperty('--color-primary-opacity', theme["primary-opacity"])
    document.documentElement.style.setProperty('--color-primary-content', theme["primary-content"])
    document.documentElement.style.setProperty('--color-secondary', theme.secondary)
    document.documentElement.style.setProperty('--color-secondary-opacity', theme["secondary-opacity"])
    document.documentElement.style.setProperty('--color-secondary-content', theme["secondary-content"])
}

export default setTheme;