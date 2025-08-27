# 🎨 CAS Art Heist - Advanced Art Theft System for RedM

A comprehensive art theft system for Red Dead Redemption 2 (RedM) servers featuring interactive NPC dealers, realistic theft mechanics, and a modern React-based UI.

## 📋 Table of Contents
- [Features](#-features)
- [Requirements](#-requirements)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Usage](#-usage)
- [Commands](#-commands)
- [Localization](#-localization)
- [Support](#-support)
- [License](#-license)

## ✨ Features

### 🎯 Core Features
- **Interactive Art Theft System**: Steal valuable statues and paintings from various locations
- **Realistic Theft Mechanics**: Use lockpicks to steal art pieces with chance-based success/failure
- **Dynamic Damage System**: Art pieces can be damaged during theft, affecting their value
- **Multiple Art Types**: Support for statues, busts, and paintings with different values
- **NPC Art Dealers**: Interactive dealers who inspect and purchase stolen art

### 🎨 Advanced UI
- **Modern React Interface**: Beautiful, responsive UI built with React and Tailwind CSS
- **Animated Interactions**: Smooth animations and transitions using Framer Motion
- **Typewriter Effect**: Dynamic text display for NPC dialogues
- **Multi-language Support**: Easy localization system

### 💰 Economic Features
- **Dynamic Pricing**: Art values fluctuate based on condition and dealer preferences
- **Scam System**: Some dealers may scam players with fake offers
- **Durability System**: Art condition affects final selling price
- **Multiple Dealers**: Different dealers with varying price ranges and reliability

### 🚛 Transportation System
- **Wagon Loading**: Load stolen art onto wagons for transport
- **Realistic Physics**: Art pieces fall and can break when dropped
- **Inventory Management**: Proper handling of stolen goods

## 🔧 Requirements

### Framework Support
- **VORP Core** or **RSG Core**
- **VORP Inventory** or **RSG Inventory**

### Dependencies
- `cas_fwlibs` - Framework library functions
- `cas-progressbar` - Progress bar system
- `cas-notification` (optional) - Notification system
- `oxmysql` - Database operations

### Optional Dependencies
- Custom notification system (configurable)

## 📦 Installation

1. **Download the Script**
   ```bash
   git clone https://github.com/codeaftersex/cas-artheist.git
   ```

2. **Place in Resources**
   - Copy the `cas-artheist` folder to your server's `resources` directory

3. **Add to server.cfg**
   ```cfg
   ensure cas-artheist
   ```

4. **Configure Dependencies**
   - Ensure all required dependencies are installed and running
   - Configure your framework (VORP/RSG) properly

5. **Database Setup**
   - No additional database tables required
   - Uses existing framework inventory systems

6. **Restart Server**
   ```bash
   restart cas-artheist
   ```

## ⚙️ Configuration

### Main Configuration (`config/shared_config.lua`)

```lua
Config.Locale = "en" -- Language setting

-- Art pieces that can be stolen
Config.ArtHeistProps = {
    "p_gen_statue02b",        -- Large statue
    "p_cherubstatuenbx01x",   -- Cherub statue  
    "p_headbust03x"           -- Head bust
}

-- Theft mechanics
Config.CutHandsChance = 0.9           -- Chance to cut hands during theft
Config.CutHandsDamage = 10            -- Damage taken when cutting hands
Config.DeleteLockPickChance = 0.9     -- Chance lockpick breaks
Config.StatueDamage = math.random(1, 100) -- Random damage to stolen art
Config.StealProgBarDuration = math.random(15000, 30000) -- Theft duration

-- Delivery locations with NPC dealers
Config.DeliveryLocations = {
    [1] = {
        name = "Saint Denis Dealer",
        coords = {x = 2705.594, y = -1105.877, z = 48.415, h = 219.542},
        pedModel = "mp_de_u_m_m_aurorabasin_01",
        pedName = "Aurora Basin",
        isScam = true,        -- This dealer might scam players
        scamChance = 0.9,     -- 90% chance to scam
        offers = {
            ["p_gen_statue02b"] = { minPrice = 1200, maxPrice = 4800 },
            ["p_cherubstatuenbx01x"] = { minPrice = 800, maxPrice = 2500 },
            ["p_headbust03x"] = { minPrice = 500, maxPrice = 1300 },
        }
    },
}
```

### Prop Positioning (`config/shared_config.lua`)
Configure how art pieces attach to player hands:

```lua
Config.PropsLocationOnHands = {
    ["p_gen_statue02b"] = {
        x = 0.8, y = 0.8, z = -0.4,
        xRot = 45.0, yRot = -45.00, zRot = 0.0,
    },
    -- Add more configurations for different art pieces
}
```

## 🎮 Usage

### For Players

1. **Acquire Lockpicks**
   - Obtain lockpicks from shops or other players
   - Use command `/addlockpick` (admin only) for testing

2. **Find Art Pieces**
   - Locate stealable art in buildings and locations
   - Approach art pieces and press `[G]` to attempt theft

3. **Steal Art**
   - Use lockpicks to steal art pieces
   - Be careful - you might cut your hands or break the lockpick
   - Art may be damaged during theft, reducing value

4. **Transport Art**
   - Pick up stolen art pieces
   - Load them onto wagons for transport
   - Be careful not to drop and break them

5. **Sell to Dealers**
   - Find NPC art dealers around the map
   - Press `[G]` near dealers to open the selling interface
   - Choose which art piece to sell
   - Dealers will inspect the art and make offers
   - Some dealers might try to scam you!

### Theft Process
1. Approach any configured art piece
2. Press `[G]` to start lockpicking
3. Complete the progress bar
4. Art piece falls and may take damage
5. Pick up the art piece
6. Transport to dealers for sale

## 🎯 Commands

### Player Commands
- No player commands available (all interactions are in-world)

### Admin Commands
```bash
/addlockpick          # Add a lockpick to your inventory
/attachtestprop       # Spawn a test art piece (for testing)
```

### Debug Commands
```bash
/boiler              # Open the dealer UI (for testing)
```

## 🌍 Localization

The script supports multiple languages. Edit `config/locale.lua` to add translations:

```lua
Locales = {
    ["en"] = {
        ["getOffer"] = "Get Offer For",
        ["steal"] = "Stealing...",
        ["pickup"] = "Pickup",
        ["putDown"] = "Put Down",
        ["cutyourhand"] = "You cut your hands.",
        ["statueDamaged"] = "The statue was damaged, its value decreased.",
        ["missingitem"] = "You are missing the lockpick",
        -- Add more translations
    },
    ["tr"] = {
        -- Turkish translations
    }
}
```

## 🔧 Advanced Configuration

### Adding New Art Pieces
1. Add the prop name to `Config.ArtHeistProps`
2. Configure hand positioning in `Config.PropsLocationOnHands`
3. Add pricing to dealer offers
4. Add UI images if needed

### Adding New Dealers
```lua
[2] = {
    name = "Valentine Dealer",
    coords = {x = -175.0, y = 627.0, z = 114.0, h = 180.0},
    pedModel = "a_m_m_unidustrial_01",
    pedName = "John Smith",
    isScam = false,
    scamChance = 0.0,
    offers = {
        ["p_gen_statue02b"] = { minPrice = 2000, maxPrice = 5000 },
    }
},
```

### Customizing Damage System
- Modify `Config.StatueDamage` for different damage ranges
- Adjust `Config.CutHandsChance` for injury probability
- Change `Config.StealProgBarDuration` for theft timing

## 🎨 UI Customization

The React-based UI can be customized by editing files in the `web/src` directory:

- `components/App.tsx` - Main UI component
- `index.css` - Styling and animations
- `assets/` - UI images and fonts

## 🐛 Troubleshooting

### Common Issues

**Art pieces not spawning:**
- Check if prop names in config match game assets
- Verify server has proper prop streaming

**Lockpicks not working:**
- Ensure `cas_fwlibs` is properly installed
- Check inventory system compatibility

**UI not showing:**
- Verify React build is up to date
- Check browser console for errors
- Ensure NUI callbacks are registered

**Dealers not responding:**
- Check NPC spawn coordinates
- Verify ped models exist in game
- Ensure proper framework integration

### Debug Mode
Enable debug mode in config:
```lua
Config.Debug = true
```

## 📞 Support

- **GitHub Issues**: [Report bugs and request features](https://github.com/codeaftersex/cas-artheist/issues)
- **Discord**: Join our community server for support
- **Documentation**: Check the wiki for detailed guides

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License. See the LICENSE file for details.

## 🙏 Credits

- **Developer**: Code After Sex Team
- **Framework**: Built for RedM/VORP/RSG
- **UI**: React + Tailwind CSS + Framer Motion
- **Special Thanks**: RedM community for testing and feedback

---

**Download**: [GitHub Repository](https://github.com/codeaftersex/cas-artheist)

**Version**: 1.0.0  
**Last Updated**: 2024

---

*Transform your RedM server with this immersive art theft experience! Perfect for roleplay servers looking to add unique criminal activities.*