# ----------- High-level API -----------
"""
Returns the ID of the CPU on which the calling thread
is currently executing.

See `sched_getcpu` for more information.
"""
getcpuid() = sched_getcpu()

"""
Returns the ID of the CPUs on which the Julia threads
are currently running. The result is ordered.

See `getcpuid` for more information.
"""
function getcpuids()
    nt = nthreads()
    cpuids = zeros(Int, nt)
    @threads :static for tid in 1:nt
        cpuids[tid] = getcpuid()
    end
    return cpuids
end

"""
Pin the calling Julia thread to the CPU with id `cpuid`.

For more information see `uv_thread_setaffinity`.
"""
pinthread(cpuid::Integer) = uv_thread_setaffinity(cpuid)

"""
Pins the first `1:length(cpuids)` Julia threads to the CPUs with ids `cpuids`.
Note that `length(cpuids)` may not be larger than `Threads.nthreads()`.

For more information see `pinthread`.
"""
function pinthreads(cpuids::AbstractVector{<:Integer})
    ncpuids = length(cpuids)
    ncpuids ≤ nthreads() || throw(ArgumentError("length(cpuids) must be ≤ Threads.nthreads()"))
    @threads :static for tid in 1:ncpuids
        pinthread(cpuids[tid])
    end
    return nothing
end