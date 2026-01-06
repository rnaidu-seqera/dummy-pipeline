#!/usr/bin/env nextflow

params.input = "test-input"
outputDir = params.outdir
params.pipeline_info = "test-pipeline-info"

process TEST {
    container 'ubuntu:22.04'
    
    output:
    stdout

    script:
    """
    echo "${outputDir}"
    """
}

workflow {
    TEST()
    TEST.out.view()
}
