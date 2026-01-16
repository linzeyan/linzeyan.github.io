#!/bin/bash

# https://github.com/GoogleContainerTools/skaffold/examples/getting-started
curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 && \
    sudo install skaffold /usr/local/bin/
