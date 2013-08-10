#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>

#import <Cocoa/Cocoa.h>

#include <netcdf.h>
OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options);
void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview);

void handle_error(int status);


/* -----------------------------------------------------------------------------
   Generate a preview for file

   This function's job is to create preview for designated file
   ----------------------------------------------------------------------------- */

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
    // To complete your generator please implement the function GeneratePreviewForURL in GeneratePreviewForURL.c
    @autoreleasepool {

        int status, ncid, ndims, nvars, ngatts, unlimdimid;

        NSString* filepath = (__bridge NSString*)CFURLCopyFileSystemPath(url, kCFURLPOSIXPathStyle);
        
        const char * cfilepath = filepath.UTF8String;
        status = nc_open(cfilepath, NC_NOWRITE, &ncid);
        if (status != NC_NOERR) handle_error(status);
        
        status = nc_inq(ncid, &ndims, &nvars, &ngatts, &unlimdimid);
        if (status != NC_NOERR) handle_error(status);

        NSString * data = [NSString stringWithFormat:@"NetCDF file %i = {\n"
                           "  Dimensions: %i\n"
                           "  Variables: %i\n"
                           "  Attributes: %i\n"
                           "  Unlimited Dim: %i\n"
                           " }\n", ncid, ndims, nvars, ngatts, unlimdimid
                           ];
        NSLog(@"QLnetcdt basic inquiry for %s", cfilepath);
        NSLog(data);
        

        for (int curvar_id = 0; curvar_id < nvars; ++curvar_id){
            char curvar_name[NC_MAX_NAME+1];      /* variable name */
            nc_type curvar_type;                   /* variable type */
            int curvar_ndims;                      /* number of dims */
            int curvar_dimids[NC_MAX_VAR_DIMS];    /* dimension IDs */
            int curvar_natts;                      /* number of attributes */

            /* we don't need name, since we already know it */
            status = nc_inq_var(ncid, curvar_id, curvar_name, &curvar_type, &curvar_ndims, curvar_dimids,
                                 &curvar_natts);
            if (status != NC_NOERR) handle_error(status);
            NSString * vardata = [NSString stringWithFormat:@"Variable Name: %s\n"
                               "  Type: %i\n"
                               "  Number of Dims: %i\n"
                               "  Dim id[0]: %i\n"
                               "  Attributes: %i\n"
                               " }\n", curvar_name, curvar_type, curvar_ndims, curvar_dimids[1], curvar_natts
                               ];
            NSLog(vardata);
        }
        
        
        

        //NSLog(@"Netcdf (status: %i), (ncid: %i), (ndims: %i), (nvars: %i), (ngatts: %i), (unlimdimid: %i),",
        //      status, ncid, ndims, nvars, ngatts, unlimdimid);

    }

    return noErr;
}

void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview)
{
    // Implement only if supported
}

/* Handles a netcdf error. */
void handle_error(int status) {
    if (status != NC_NOERR) {
        NSLog(@"QLnetcdf generator is having problems trying to open a file. See stderr.");
        fprintf(stderr, "%s\n", nc_strerror(status));
        exit(-1);
    }
}
