/^def build_from_source(/,/^[^ \)]/{
  /^    args = /,/^    \]/{
    s,^    \],&\n\n    # added by *-mx-katee.git/scripts/add-my_mxbuild_args.sed BEGIN\n    my_model_version = os.environ.get("MY_MODEL_VERSION")\n    if my_model_version:\n        args.append("--model-version=%s" % my_model_version)\n    # added by *-mx-katee.git/scripts/add-my_mxbuild_args.sed END,
    T
    # consume the rest and exit 0:
    :L1
    n
    b L1
  }
}
# exit 1:
$q1
