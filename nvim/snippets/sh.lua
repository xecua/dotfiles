return {
    dirname = {
        prefix = "dirname",
        body = [[$0=\$(cd "\$(realpath \$(dirname \$0))"; pwd)]],
    },
}
