SLANG_SRC_PATH :: "lib/include";

#run generate_bindings();

generate_bindings :: () -> bool {
    output_filename: string;
    opts: Generate_Bindings_Options;
    {
        using opts;
        slang_lib_path: string;
        output_filename = "slang.jai";

        #if OS == .WINDOWS {
            slang_lib_path = "lib/win";
        } else {
            assert(false);
        }

        array_add(*libpaths, slang_lib_path);
        array_add(*libnames, "slang");

        array_add(*source_files, tprint("%/slang.h", SLANG_SRC_PATH));

        array_add(*flatten_namespaces, "slang");

        array_add(*extra_clang_arguments, "-x", "c++", "-DWIN32_LEAN_AND_MEAN");

        mimic_spacing_flags &= ~(Mimic_Spacing_Flags.VTABLE);
        log_stripped_declarations = false;
        // generate_compile_time_struct_checks = false;
    }

    return generate_bindings(opts, output_filename);
}

#scope_file

#import "Basic";
#import "Bindings_Generator";
#import "Compiler";
#import "File";
#import "String";