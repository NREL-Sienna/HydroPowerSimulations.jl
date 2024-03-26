using Revise
using PowerSystems
using PowerSimulations
using PowerSystemCaseBuilder
using PowerNetworkMatrices
using HydroPowerSimulations
using DataFrames
using CSV
using Dates
using InfrastructureSystems
using Test
using Logging

import Aqua
Aqua.test_unbound_args(HydroPowerSimulations)
Aqua.test_undefined_exports(HydroPowerSimulations)
Aqua.test_ambiguities(HydroPowerSimulations)

LOG_FILE = "power-systems.log"
LOG_LEVELS = Dict(
    "Debug" => Logging.Debug,
    "Info" => Logging.Info,
    "Warn" => Logging.Warn,
    "Error" => Logging.Error,
)

# Constants
# Constants
const PSY = PowerSystems
const PSI = PowerSimulations
const PSB = PowerSystemCaseBuilder
const IS = InfrastructureSystems
const PM = PSI.PM
const PNM = PowerNetworkMatrices

# Test Utils
using JuMP
using HiGHS

HiGHS_optimizer = JuMP.optimizer_with_attributes(
    HiGHS.Optimizer,
    "time_limit" => 300.0,
    "log_to_console" => false,
    "mip_abs_gap" => 1e-1,
    "mip_rel_gap" => 1e-1,
)

ENV["RUNNING_PSI_TESTS"] = "true"

# Load
PSI_DIR = string(dirname(dirname(pathof(PowerSimulations))))
include(joinpath(PSI_DIR, "test/test_utils/solver_definitions.jl"))
include(joinpath(PSI_DIR, "test/test_utils/mock_operation_models.jl"))
include(joinpath(PSI_DIR, "test/test_utils/operations_problem_templates.jl"))
include(joinpath(PSI_DIR, "test/test_utils/model_checks.jl"))

"""
Copied @includetests from https://github.com/ssfrr/TestSetExtensions.jl.
Ideally, we could import and use TestSetExtensions.  Its functionality was broken by changes
in Julia v0.7.  Refer to https://github.com/ssfrr/TestSetExtensions.jl/pull/7.
"""

"""
Includes the given test files, given as a list without their ".jl" extensions.
If none are given it will scan the directory of the calling file and include all
the julia files.
"""
macro includetests(testarg...)
    if length(testarg) == 0
        tests = []
    elseif length(testarg) == 1
        tests = testarg[1]
    else
        error("@includetests takes zero or one argument")
    end

    quote
        tests = $tests
        rootfile = @__FILE__
        if length(tests) == 0
            tests = readdir(dirname(rootfile))
            tests = filter(
                f ->
                    startswith(f, "test_") && endswith(f, ".jl") && f != basename(rootfile),
                tests,
            )
        else
            tests = map(f -> string(f, ".jl"), tests)
        end
        println()
        for test in tests
            print(splitext(test)[1], ": ")
            include(test)
            println()
        end
    end
end

function get_logging_level_from_env(env_name::String, default)
    level = get(ENV, env_name, default)
    return IS.get_logging_level(level)
end

function run_tests()
    logging_config_filename = get(ENV, "SIIP_LOGGING_CONFIG", nothing)
    if logging_config_filename !== nothing
        config = IS.LoggingConfiguration(logging_config_filename)
    else
        config = IS.LoggingConfiguration(;
            filename=LOG_FILE,
            file_level=Logging.Info,
            console_level=Logging.Error,
        )
    end
    console_logger = ConsoleLogger(config.console_stream, config.console_level)

    IS.open_file_logger(config.filename, config.file_level) do file_logger
        levels = (Logging.Info, Logging.Warn, Logging.Error)
        multi_logger =
            IS.MultiLogger([console_logger, file_logger], IS.LogEventTracker(levels))
        global_logger(multi_logger)

        if !isempty(config.group_levels)
            IS.set_group_levels!(multi_logger, config.group_levels)
        end

        # Testing Topological components of the schema
        @time @testset "Begin HydroPowerSimulations tests" begin
            @includetests ARGS
        end

        @test length(IS.get_log_events(multi_logger.tracker, Logging.Error)) == 0
        @info IS.report_log_summary(multi_logger)
    end
end

logger = global_logger()

try
    run_tests()
finally
    # Guarantee that the global logger is reset.
    global_logger(logger)
    nothing
end
