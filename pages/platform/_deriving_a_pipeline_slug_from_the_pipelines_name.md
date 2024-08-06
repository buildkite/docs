Pipeline slugs are derived from the pipeline name you provide when the pipeline is created (unless you use the optional `slug` parameter to specify a custom slug).

This derivation process involves converting all space characters (including consecutive ones) in the pipeline's name to single hyphen `-` characters, and all uppercase characters to their lowercase counterparts. Therefore, pipeline names of either `Hello there friend` or `Hello    There Friend` are converted to the slug `hello-there-friend`.

The maximum permitted length for a pipeline slug is 100 characters.

> 📘
> The following regular expression is used to derive and convert the pipeline name to its slug:
> `/\A[a-zA-Z0-9]+[a-zA-Z0-9\-]*\z/`
