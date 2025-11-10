#!/usr/bin/env nextflow

params.efs_file_system_id = "fs-12345678"  // Replace with actual EFS ID if testing real mount

process testWriteToMount {
    debug true
    
    script:
    """
    echo "=== Checking mount points ==="
    df -h
    echo ""
    
    echo "=== Checking if /staging/scratch exists ==="
    ls -la /staging/ || echo "/staging does not exist"
    echo ""
    
    echo "=== Checking what's mounted at /staging/scratch ==="
    df -h /staging/scratch 2>/dev/null || echo "Cannot determine filesystem for /staging/scratch"
    mount | grep staging || echo "No /staging mount found in mount table"
    echo ""
    
    echo "=== Attempting to write test file ==="
    mkdir -p /staging/scratch
    echo "Test file written at \$(date)" > /staging/scratch/test_file_\${HOSTNAME}_\${AWS_BATCH_JOB_ID}.txt
    
    echo "=== Verifying file was written ==="
    ls -la /staging/scratch/
    cat /staging/scratch/test_file_\${HOSTNAME}_\${AWS_BATCH_JOB_ID}.txt
    
    echo ""ß
    echo "=== Checking filesystem type and mount info for the written file ==="
    df -hT /staging/scratch/
    stat -f /staging/scratch/ || stat --file-system /staging/scratch/
    """
}

workflow {
    testWriteToMount()
}
