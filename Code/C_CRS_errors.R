###############################
# Authors:
# Marco A. Aquino-López 
# Code:
# Runs the CRS and genertes file 
###############################
setwd(".")
# Load the CRS function
source("./CRS_function.R")  # Replace with actual path

# Setup working directory and core list
wd <- "./Plum_runs/"
cores <- list.files(wd)
# cores <- cores[grepl(".csv", cores) & !grepl("E-CRS|_ages|E-CRS.csv", cores)] # avoid non-core files
# cores <- gsub(".csv", "", cores)
# Get only folders that match core naming pattern: SimXX_YY_ZZZ
cores <- list.dirs(wd, full.names = FALSE, recursive = FALSE)
cores <- cores[grepl("^Sim\\d{2}_\\d{2,3}_\\d{3}$", cores)]

modelMeans_CRS <- NULL
errors_CRS <- NULL

for (kore in 1:length(cores)) {
  path <- paste0(wd, cores[kore], "/", cores[kore], ".csv")
  if (!file.exists(path)) {
    warning(paste("File not found:", path))
    next
  }

  tryCatch({
    dts <- read.table(path, header = TRUE, sep = ",")
    
    # Apply CRS model
    crs <- CRS(dts[,2], dts[,4], dts[,5], dts[,3], mean(dts[,7]), mean(dts[,8]))
    crs$Ages <- crs$Ages + 70  # Adjust age if needed

    # Evaluate true age model (e.g., f1, f2, f3) — you can adapt this as in your code
    id_code <- substr(cores[kore], 7, 8)
    f <- switch(id_code,
                "01" = 0:30^2 / 4 + 0:30 / 2,
                "02" = 12 * (0:30) - 0.2 * (0:30)^2,
                8 * (0:30) + 25 * sin((0:30)/pi))  # default f3

    # Compute offsets
    age <- crs$Ages
    depth <- crs$Depths
    err <- crs$Errors
    offset <- abs(age - f[depth + 1])
    Noffset <- offset / err
    result <- data.frame(depth = depth, age = age, sd = err, offset = offset, N_offset = Noffset)

    write.csv(result, paste0(wd, cores[kore], "/CRS_result.csv"), row.names = FALSE)

    if (nrow(result) > 2) {
      modelMeans_CRS <- rbind(modelMeans_CRS, c(core = cores[kore], colMeans(result[-1, ], na.rm = TRUE)))
    } else {
      modelMeans_CRS <- rbind(modelMeans_CRS, c(core = cores[kore], result[-1, ]))
    }

  }, error = function(e) {
    message(paste("Error in core", cores[kore], ":", e$message))
    errors_CRS <<- rbind(errors_CRS, data.frame(core = cores[kore], error = e$message))
  })
}

# Write summary and error files
write.table(modelMeans_CRS, paste0("CRS_error.txt"), col.names = TRUE, row.names = FALSE, quote = FALSE)

