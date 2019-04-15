FROM alpine:latest
MAINTAINER Ambroise Maupate <ambroise@rezo-zero.com>

RUN apk --no-cache add make py3-pip python3-dev && \
    pip3 install sphinx && \
    pip3 install sphinx_rtd_theme && \
    pip3 install sphinx-autobuild && \
    pip3 install pygments-markdown-lexer && \
    pip3 install recommonmark
