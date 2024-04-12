# nginx docker images
These images contain nginx. These images do not have support for templating of
nginx config files (in contrast to the official nginx docker images) and don't
do any other pre-processing of your configuration files, you probably always
want to set it up with your own configuration files.

## Available versions
- mainline: `mainline`, `latest` Offers the latest features, might be more
  unstable and is updated more frequently.
- stable: `stable` Offers a more stable version, a little more outdated and
  less frequently updated.

In general for most of our projects you can safely select the `stable` version,
but it might get updated to a newer major or minor version automatically in the
future.
