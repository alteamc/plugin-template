package com.example.myawesomeplugin;

import org.bukkit.plugin.java.JavaPlugin;
import org.jetbrains.annotations.NotNull;

public final class MyAwesomePlugin extends JavaPlugin {
    @SuppressWarnings("NotNullFieldNotInitialized")
    private static @NotNull MyAwesomePlugin I;

    @Override
    public void onEnable() {
        I = this;
    }

    @Override
    public void onDisable() {
        //noinspection ConstantConditions
        I = null;
    }

    public static @NotNull MyAwesomePlugin getInstance() {
        return I;
    }
}
