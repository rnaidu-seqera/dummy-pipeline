#!/usr/bin/env nextflow

process HELLO {
    output:
    stdout

    script:
    """
    echo "Testing schema: ${params.test_param ?: 'default'}"
    """
}

workflow {
    HELLO()
}