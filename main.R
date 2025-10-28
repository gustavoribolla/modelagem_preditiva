# main.R — Executor dos exercícios
# Roda scripts em code/: Q1.R, Q2.R, Q3.R, Q4.R, A1.R, A2.R

set.seed(42)

# Garante pastas mínimas
invisible(lapply(c("code", "data", "images"),
                 function(d) if (!dir.exists(d)) dir.create(d, recursive = TRUE)))

# Coleta scripts no padrão mostrado (Qn.R e An.R)
scripts <- list.files("code", pattern = "^[QA][0-9]+\\.R$", full.names = TRUE)
if (length(scripts) == 0) stop("Nenhum arquivo 'Qn.R' ou 'An.R' encontrado em 'code/'.")

# Funções auxiliares para ordenar: prefixo (Q<A) e número
get_prefix <- function(x) substr(basename(x), 1, 1)
get_num    <- function(x) as.integer(gsub("\\D", "", basename(x)))

ord <- order(match(get_prefix(scripts), c("Q", "A")),
             get_num(scripts),
             na.last = TRUE)
scripts <- scripts[ord]

cat("Arquivos detectados (ordem de execução):\n",
    paste0(" - ", basename(scripts), collapse = "\n"),
    "\n\n", sep = "")

# Executa cada script isolado
for (path in scripts) {
  cat(">>> Iniciando ", basename(path), "...\n", sep = "")
  tryCatch(
    {
      source(path, local = new.env(parent = globalenv()))
      cat(">>> Concluído ", basename(path), ".\n\n", sep = "")
    },
    error = function(e) {
      cat("[ERRO] em ", basename(path), ": ", conditionMessage(e), "\n\n", sep = "")
    },
    warning = function(w) {
      cat("[AVISO] em ", basename(path), ": ", conditionMessage(w), "\n\n", sep = "")
    }
  )
}