params.fastq ="/media/amal-dev-r/ExternalHDD/RNA-seq/test/*.fastq.gz"
params.fastqc ="/media/amal-dev-r/ExternalHDD/RNA-seq/RESULTS/Fastp_results/*_clean.fastq.gz"

process FASTP{
    container 'biocontainers/fastp:v0.20.1_cv2'
    publishDir '/media/amal-dev-r/ExternalHDD/RNA-seq/RESULTS/Fastp_results', mode: 'copy'

    input:
    path fastq

    output: 
    path "*"

    script:
    """
    fastp -i $fastq -o ${fastq.baseName}_clean.fastq.gz
    """
}

process FASTQC {
    container 'biocontainers/fastqc:v0.12.1_cv8'
    publishDir '/media/amal-dev-r/ExternalHDD/RNA-seq/RESULTS/Fastqc_results', mode: 'copy'

    input:
    path fastpq

    output: 
    path "*"

    script:
    """
    fastqc $fastpq
    """
}

workflow {
    fastp_ch = Channel.fromPath(params.fastq)
    FASTP(fastp_ch)
    FASTP.out.view()

    fastqc_ch = Channel.fromPath(params.fastqc)
    FASTQC(fastqc_ch)
    FASTQC.out.view()
}
