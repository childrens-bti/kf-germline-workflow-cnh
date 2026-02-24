# Docker Images Build Instructions

This directory contains Dockerfiles for building custom images for the germline workflow.

## Building the Images

### AnnotSV 3.5.3
```bash
docker build -f Dockerfiles/annotsv.Dockerfile -t pgc-images.sbgenomics.com/childrens-bti/annotsv:3.5.3 .
```

### SvABA 1.2.0
```bash
docker build -f Dockerfiles/svaba.Dockerfile -t pgc-images.sbgenomics.com/childrens-bti/svaba:1.2.0 .
```

## Pushing to Seven Bridges Registry

First, log in to the Seven Bridges registry:
```bash
docker login pgc-images.sbgenomics.com
```

Then push the images:
```bash
docker push pgc-images.sbgenomics.com/childrens-bti/annotsv:3.5.3
docker push pgc-images.sbgenomics.com/childrens-bti/svaba:1.2.0
```

## Testing the Images

### Test AnnotSV
```bash
docker run --rm pgc-images.sbgenomics.com/childrens-bti/annotsv:3.5.3 AnnotSV -help
```

### Test SvABA
```bash
docker run --rm pgc-images.sbgenomics.com/childrens-bti/svaba:1.2.0 svaba --help
```

## Notes

- Ensure you have permissions to push to the `childrens-bti` namespace on Seven Bridges
- The images are built from official source repositories at the specified versions
- AnnotSV requires annotation data to be provided at runtime via the workflow inputs
