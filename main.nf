#!/usr/bin/env nextflow

params.input = "test-input"
params.outdir = "test-output"
params.pipeline_info = "test-pipeline-info"

process TEST {
    container 'ubuntu:22.04'
    
    output:
    stdout

    script:
    """
    echo "${params.outdir}"
    """
}

workflow {
    TEST()
    TEST.out.view()
}
