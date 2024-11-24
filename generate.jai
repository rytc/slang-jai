SLANG_SRC_PATH :: "lib/include";

#run generate_bindings();

generate_bindings :: () -> bool {
    set_build_options_dc(.{ do_output=false });

    output_filename: string;
    opts: Generate_Bindings_Options;
    {
        using opts;

        if OS == {
            case .WINDOWS; output_filename = "windows.jai";
            case .LINUX; output_filename = "linux.jai";
        }

        if OS == {
            case .WINDOWS; array_add(*libpaths, "./lib/win");
            case .LINUX; array_add(*libpaths, "./lib/linux");
        }

        if OS == {
            case .WINDOWS; array_add(*libnames, "slang");
            case .LINUX; array_add(*libnames, "libslang");
        }

        array_add(*source_files, tprint("%/slang.h", SLANG_SRC_PATH));

        array_add(*flatten_namespaces, "slang");

        array_add(*extra_clang_arguments, "-x", "c++");
        #if OS == .WINDOWS {
            array_add(*extra_clang_arguments, "-DWIN32_LEAN_AND_MEAN");
        }

        mimic_spacing_flags &= ~(Mimic_Spacing_Flags.VTABLE);
        log_stripped_declarations = false;
        // generate_compile_time_struct_checks = false;

        generate_library_declarations=false;
        visitor=slang_visitor;
    }

    return generate_bindings(opts, output_filename);
}

#scope_file

slang_visitor :: (decl: *Declaration, parent_decl: *Declaration) -> result: Declaration_Visit_Result = .RECURSE {
    // This is being set to an invalid `~u64(0)`, so manually setting it to `U64_MAX` to make it unbounded.
    if decl.name == "SLANG_UNBOUNDED_SIZE" {
        literal := cast(*Literal) decl.expression;
        literal.raw_value = tprint("%", U64_MAX);
    }

    return;
}

#import "Basic";
#import "Math";
#import "Bindings_Generator";
#import "Compiler";
#import "File";
#import "String";
