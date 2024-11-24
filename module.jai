#if OS == .WINDOWS {
    #load "windows.jai";
} else #if OS == .LINUX {
    #load "linux.jai";
} else {
    #assert false "Unsupported OS for Slang";
}

#if OS == .WINDOWS {
    slang :: #library "lib/win/slang";
} else #if OS == .LINUX {
    libslang :: #library "lib/linux/libslang";
}
