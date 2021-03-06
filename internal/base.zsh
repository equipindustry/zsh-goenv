#!/usr/bin/env ksh
# -*- coding: utf-8 -*-

function goenv::internal::goenv::install {
    message_info "Installing ${GOENV_PACKAGE_NAME}"
    git clone https://github.com/syndbg/goenv.git ~/.goenv
    message_success "Installed ${GOENV_PACKAGE_NAME}"
}

function goenv::internal::init {
    local goenv_path goenv_global goroot
    goenv_path=$(go env GOPATH)
    goenv_global=$(goenv global)
    goroot=$(goenv prefix)
    eval "$(goenv init -)"
    [ -e "${GOPATH}/bin" ] && export PATH="${goenv_path}/bin:${PATH}"
    [ -e "${GOENV_ROOT}/versions/${goenv_global}/bin" ] && export PATH="${GOENV_ROOT}/versions/${goenv_global}/bin:${PATH}"
    export GOROOT="${goroot}"
}

function goenv::internal::load {
    goenv::internal::init
    [ -e "${GOENV_ROOT}/bin" ] && export PATH="${PATH}:${GOENV_ROOT}/bin"
    [ -e "${GOENV_ROOT}/shims" ] && export PATH="${GOENV_ROOT}/shims:${PATH}"
    if type -p goenv > /dev/null; then
        goenv::internal::init
        [ -e "${GOROOT}/bin" ] && export PATH="${GOROOT}/bin:${PATH}"
        [ -e "${GOPATH}/bin" ] && export PATH="${PATH}:${GOPATH}/bin"
        export GO111MODULES=on
    fi
}

function goenv::internal::packages::install {
    if ! type -p go > /dev/null; then
        message_warning "it's neccesary have go"
        return
    fi

    message_info "Installing required go packages"
    # binary will be $(go env GOPATH)/bin/golangci-lint
    curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b "$(go env GOPATH)"/bin v1.27.0

    for package in "${GOENV_PACKAGES[@]}"; do
       GO111MODULE=on go get -u -v "${package}"
    done
    message_success "Installed required Go packages"
}

function goenv::internal::version::all::install {
    if ! type -p goenv > /dev/null; then
        message_warning "not found goenv"
        return
    fi

    for version in "${GOENV_VERSIONS[@]}"; do
        message_info "Install version of go ${version}"
        goenv install "${version}"
        message_success "Installed version of go ${version}"
    done
    goenv global "${GOENV_VERSION_GLOBAL}"
    message_success "Installed versions of Go"

}

function goenv::internal::version::global::install {
    if ! type -p goenv > /dev/null; then
        message_warning "not found goenv"
        return
    fi
    message_info "Installing version global of go ${GOENV_VERSION_GLOBAL}"
    goenv install "${GOENV_VERSION_GLOBAL}"
    message_success "Installed version global of go ${GOENV_VERSION_GLOBAL}"
}

function goenv::internal::upgrade {
    message_info "Upgrade for ${GOENV_PACKAGE_NAME}"
    local path_goenv
    path_goenv=$(goenv root)
    # shellcheck disable=SC2164
    cd "${path_goenv}" && git pull && cd -
    message_success "Upgraded ${GOENV_PACKAGE_NAME}"
}