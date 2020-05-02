import yaml

d = None
with open("../macros/sysenter_vectors.yaml") as f:
    d = yaml.load(f)

with open("../macros/sysenter_vectors.asm", "w") as f:

    f.write("; Generated from tools/make_sysenter_vectors.py\n\n")
    idx = 0
    for k, v in d.items():
        in_registers = v.get("in")
        out_registers = v.get("out")
        doc = v.get("doc")
        if doc:
            f.write("; {}\n".format(doc))
        if in_registers:
            f.write("; IN = ")
            f.write(", ".join(["{}: {}".format(reg, doc) for reg, doc in  in_registers.items()]))
            f.write("\n")
        if out_registers:
            f.write("; OUT = ")
            f.write(", ".join(["{}: {}".format(reg, doc) for reg, doc in out_registers.items()]))
            f.write("\n")

        f.write("%define os_{} {}\n\n".format(k, idx))
        idx += 1

with open("../src/features/sysenter_vectors_list.asm", "w") as f:

    f.write("; Generated from tools/make_sysenter_vectors.py\n\n")
    f.write("kernel_system_calls:\n")
    idx = 0
    for k, v in d.items():
        f.write("    dd kernel_syscall_{} ; {}\n".format(k, idx))
        idx += 1
    f.write("\nkernel_system_calls_end:")


