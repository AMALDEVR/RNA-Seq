params.fastq ="/media/amal-dev-r/ExternalHDD/RNA-seq/test/*{1,2}.fastq.gz"
params.fastqc ="/media/amal-dev-r/ExternalHDD/RNA-seq/RESULTS/Fastp_results/*_clean.fastq.gz"

process FASTP{
    container 'biocontainers/fastp:v0.20.1_cv2'
    publishDir '/media/amal-dev-r/ExternalHDD/RNA-seq/RESULTS/Fastp_results', mode: 'copy'

    input:
    tuple val(sample_id), path(reads)

    output: 
    tuple val(sample_id),
    path("${sample_id}_1_clean.fastq.gz"),
    path("${sample_id}_2_clean.fastq.gz"), emit:cleaned_reads

    script:
    """
    fastp -i ${reads[0]} -I ${reads[1]} -o ${sample_id}_1_clean.fastq.gz -O ${sample_id}_2_clean.fastq.gz
    """
}

process FASTQC {
    container 'biocontainers/fastqc:v0.12.1_cv8'
    publishDir '/media/amal-dev-r/ExternalHDD/RNA-seq/RESULTS/Fastqc_results', mode: 'copy'

    input:
    tuple val(sample_id), path(reads1), path(reads2)

    output: 
    path "*.html", emit:html
    path "*.zip", emit:zip

    script:
    """
    fastqc ${reads1} ${reads2}
    """
}

process MULTIQC {
   /* container 'quay.io/biocontainers/multiqc:1.21--pyhdfd78af_0' */
    publishDir '/media/amal-dev-r/ExternalHDD/RNA-seq/RESULTS/Multiqc_results', mode: 'copy'

    input:
    path fastqc_results

    output: 
    path "*"

    script:
    """
    multiqc .
    """
}
/*
process SALMON {
    container 'biocontainers/salmon:v1.5.2_cv1'
    publishDir '/media/amal-dev-r/ExternalHDD/RNA-seq/RESULTS/Salmon_results', mode: 'copy'

    input:
    tuple val(sample_id),
    path (read1),
    path (read2)

    output: 
    path "*"

    script:
    """
    salmon quant -i /home/amal-dev-r/Documents/self_project/RNA_seq/salmon_ref/Salmon_index -l A -1 ${read1} -2 ${read2} -p 4 --validateMappings -o /media/amal-dev-r/ExternalHDD/RNA-seq/RESULTS/Salmon_output/${sample_id}_quant
    """
}
*/
workflow {
    fastp_ch = Channel.fromFilePairs(params.fastq, checkIfExists: true)
    FASTP(fastp_ch) 
    FASTP.out.cleaned_reads.view()
    
    FASTQC(FASTP.out.cleaned_reads)
    MULTIQC(FASTQC.out.zip)
    /*
    SALMON(FASTP.out.cleaned_reads)
    */
}
