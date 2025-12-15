#!/usr/bin/env nextflow

params.input = "test-input"
params.outdir = "test-output"
params.pipeline_info = "test-pipeline-info"

process TEST {
    output:
    stdout

    script:
    """
    echo "Test complete"
    """
}

workflow {
    TEST()
}
