// Loosly based off of https://github.com/shader-slang/slang/blob/master/examples/hello-world/main.cpp
// http://shader-slang.com/slang/user-guide/compiling

main :: () {
    log("Creating global session");
    global_session: *slang.IGlobalSession;
    slang.slang_createGlobalSession(slang.SLANG_API_VERSION, *global_session);

    session_desc: slang.SessionDesc;
    target_desc: slang.TargetDesc;

    target_desc.format = .SLANG_SPIRV;
    target_desc.profile = slang.IGlobalSession_findProfile(global_session, to_c_string("spirv_1_5"));

    session_desc.targets = *target_desc;
    session_desc.targetCount = 1;

    options: [..]slang.CompilerOptionEntry;
    array_add(*options, .{
        slang.CompilerOptionName.EmitSpirvDirectly, .{
            slang.CompilerOptionValueKind.Int, 1, 0, null ,null
        }
    });
    session_desc.compilerOptionEntries = options.data;
    session_desc.compilerOptionEntryCount = cast(u32)options.count;

    log("Creating session");
    session: *slang.ISession;
    slang.IGlobalSession_createSession(global_session, *session_desc, *session);

    log("Loading module");
    slang_module := slang.ISession_loadModule(session, to_c_string("hello-world.slang"));
    
    log("Finding entry point");
    entry_point: *slang.IEntryPoint;
    slang.IModule_findEntryPointByName(slang_module, to_c_string("computeMain"), *entry_point);
    
    component_types: [..]*slang.IComponentType;
    array_add(*component_types, slang_module);
    array_add(*component_types, entry_point);

    log("Creating composed program");
    diagnostic_blob: *slang.IBlob;
    composed_program: *slang.IComponentType;
    slang.ISession_createCompositeComponentType(session, component_types.data, component_types.count, *composed_program, *diagnostic_blob);

    log("Getting code");
    spirv_code: *slang.IBlob;
    slang.IComponentType_getEntryPointCode(composed_program, 0, 0, *spirv_code);

    spirv_code_raw := string.{
        data = slang.ISlangBlob_getBufferPointer(spirv_code),
        count = cast(s64)slang.ISlangBlob_getBufferSize(spirv_code)
    };

    log("SPIRV output:");

    log("%", spirv_code_raw);        
}

#import "Basic";
#import "String";

slang :: #import,file "../module.jai";