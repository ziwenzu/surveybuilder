#' Output a survey into .tex or .pdf format
#'
#' @param ... A list of questions or survey modules
#' @param type The type of question to create ("Open", etc.)
#' @return A survey question
#' @export
make_survey <- function(...,output_file_path = NULL,N_surveys = NULL,survey_title = NULL,ID = NULL,compile_PDF = TRUE,store_tex = FALSE,page_numbers = TRUE){

  # Warnings and errors -----------------------------------------------------

  if (compile_PDF == FALSE & store_tex == FALSE) {
    warning(
      "You are neither compiling PDFs or storing the .tex files, so there will be no output. Please select at least one kind of output."
    )
  }

  if((!is.null(ID)&!is.null(N_surveys))&(!identical(length(ID),N_surveys))){
    stop("Your custom ID variable must be the same length as the number of surveys (N_surveys). It is better to specify only one of the two.")
  }

  if(is.null(N_surveys)){
    if(!is.null(ID)){
      N_surveys <- length(ID)
    }else{
      N_surveys <- 1
      ID <- 1
    }
  }
  if(is.null(ID)&!is.null(N_surveys)){
    ID <- 1:N_surveys
  }

  # Generate question list --------------------------------------------------

  question_list <- make_question_list(...)

  questions <- question_list_to_string(question_list)

  surveys <- lapply(1:N_surveys,function(i) {
    id <- ID[i]
    survey <- make_survey_object(survey_title = survey_title,ID = id,questions = questions)
    return(survey)
  })

  # Create file path --------------------------------------------------------

  if (is.null(output_file_path)) {
    output_file_path <- paste0(getwd(),"/surveys")
    warning(paste0(
      "No output_file_path specified for surveys, outputting them to ",output_file_path
    ))
  }

  # Generate pdfs -----------------------------------------------------------

  dir.create(output_file_path)

  file.copy(
    from = paste0(path.package("surveybuilder"),"/paperandpencil.sty"),
    to = output_file_path,
    overwrite = FALSE
  )

  for (i in 1:length(surveys)){

    survey_temp <- surveys[[i]]
    tex_name_temp <- paste0(gsub(
      pattern = " ",replacement = "_",x = tolower(survey_temp$survey_title)),"_",
      survey_temp$ID,".tex")

    compile_survey_object(survey_object = survey_temp,
                          output_file_path = output_file_path,
                          compile_PDF = compile_PDF,
                          create_directory = TRUE,
                          keep_tex = store_tex,
                          use_custom_.sty = TRUE,
                          tex_name = tex_name_temp,
                          page_numbers = TRUE)
  }

  file.remove(paste0(output_file_path,"/paperandpencil.sty"))

}


#' @export
compile_survey_object <-
  function(survey_object,output_file_path = getwd(),tex_name = NULL,compile_PDF = TRUE,create_directory = FALSE,keep_tex = TRUE,use_custom_.sty = FALSE,page_numbers = TRUE) {
    initial_WD <- getwd()

    require(tools)

    if (class(survey_object) != "survey") {
      stop("Please provide a 'survey' created with make_survey().")
    }

    if (create_directory == TRUE) {
      dir.create(output_file_path,showWarnings = F)
    }

    id <- survey_object$ID
    survey_title <- survey_object$survey_title
    questions <- survey_object$questions

    if (!file.exists(output_file_path)) {
      stop("You must provide a directory that already exists or set create_directory to true.")}

    if(!is.null(tex_name)){
      tex_path <- paste0(output_file_path,"/",tex_name)
    }else{if(!is.null(survey_title)) {
      tex_name <-
        gsub(
          pattern = " ",replacement = "_",x = tolower(survey_title)
        )
      tex_path <- paste0(output_file_path,"/",tex_name,".tex")
    }else{
      tex_path <- paste0(output_file_path,"/","survey.tex")
      message(paste0("No survey name provided in file_path, defaulted to ",
                     tex_path))
    }}

    if(!is.null(survey_title)){
      title <- paste0("\\begin{center}\\LARGE \n ",survey_title,"\\end{center} \n")
    }else{title <- NULL}

    setwd(output_file_path)

    if(!use_custom_.sty){
      file.copy(
        from = paste0(path.package("surveybuilder"),"/paperandpencil.sty"),
        to = output_file_path,
        overwrite = FALSE
      )
    }

    sink(tex_path)
    cat(readLines(paste0(
      path.package("surveybuilder"),
      "/survey_header.txt"
    )),sep = "\n")
    if(!is.null(id)){
      cat(paste0(
        "\\usepackage{fancyhdr} \n\\pagestyle{fancy} \n\\fancyhf{} \n",
        "\\rhead{ID: ", id,"} \n",
        "\\lfoot{ID: ", id,"} \n"))
    }
    if(page_numbers){
      "\rfoot{Page \thepage}"
    }
    cat(readLines(paste0(
      path.package("surveybuilder"),
      "/begin_document.txt"
    )),sep = "\n")
    cat(title,sep = "\n")
    cat(questions,sep = "\n")
    cat("\\end{document}")
    sink()


    texi2pdf(file = tex_path,clean = T)

    if(!use_custom_.sty){
      file.remove(paste0(output_file_path,"/paperandpencil.sty"))
    }
    if (!keep_tex) {
      file.remove(tex_path)
    }

    setwd(initial_WD)

    message(paste0("PDFs output to ",output_file_path))

  }

#' @export
make_question_list <- function(...){
  question_list <- list(...)

  if (length(question_list) == 1 &
      class(question_list[[1]]) == "list") {
        question_list <- question_list[[1]]
      }
  return(question_list)
}

#' @export
question_list_to_string <- function(question_list) {


  random_scheme <- get_randomization_scheme(question_list)

  question_names <- get_names(question_list = question_list,
                                  random_scheme = random_scheme,
                                  as_list = FALSE)

  questions <- unlist(question_list)
  names(questions) <- question_names

  class(questions) <- "questions"
  return(questions)

}



#' @export
remaindr <- function(numerator,denominator) {
  m_each <- rep(numerator %/% denominator, denominator)
  remainder <- numerator %% denominator
  m_each <-
    m_each + ifelse(1:denominator %in% sample(1:denominator, remainder), 1, 0)
  return(m_each)
}

#' @export
make_survey_object <- function(ID,survey_title,questions) {
  survey <-
    list(ID = ID,survey_title = survey_title, questions = questions)
  class(survey) <- "survey"
  return(survey)
}







#' @export
check_list_structure <-  function(question_list){

  question_classes <- sapply(question_list,class)

  if(any(!question_classes %in% c("character","list"))){
    stop("All questions must be either in character format (for non-randomized questions) or in list format (for randomized questions).")
  }

  more_than_one <- sapply(question_list,length)>1

  too_many_levels <- sapply(1:length(more_than_one),function(i){
    if(more_than_one[i]){
      any(!sapply(question_list[[i]],class)  %in%  "character")
    }else{
      FALSE
    }
  })

  if(any(too_many_levels)){
    stop("The list of questions should only contain two levels: the first should contain either questions (of 'character' class) or lists of questions; the second should contain a vector of questions to be randomized (also in 'character' class)")
  }

}

#' @export
get_randomization_scheme <- function(question_list){
  check_list_structure(question_list)
  sapply(question_list,class)=="list"
}



#' @export
get_names <- function(question_list,random_scheme,as_list = TRUE){
  question_names <- names(question_list)
  question_structure <- lapply(1:length(random_scheme),function(i){
    if(random_scheme[i]){
      random_names <- names(question_list[[i]])

      if(is.null(random_names)){
        random_names <- 1:length(question_list[[i]])
      }

      paste0(question_names[i],"_",random_names)
    }else{
      question_names[i]
    }
  })
  if(as_list)return(question_structure)
  return(unlist(question_structure))

}





