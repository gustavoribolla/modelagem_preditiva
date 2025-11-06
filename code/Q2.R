# Q2 - California Housing — árvore, bagging e subespaço (simples)

set.seed(42)
suppressPackageStartupMessages(library(tree))

# Pastas necessárias
for (d in c("images/Q2", "results")) dir.create(d, showWarnings = FALSE, recursive = TRUE)

# Helper para localizar o CSV
find_file <- function(fname) {
  cand <- c(file.path("data", fname),
            fname,
            file.path("..", "data", fname))
  hit <- cand[file.exists(cand)]
  if (!length(hit)) stop(sprintf("Arquivo '%s' não encontrado. Coloque-o em 'data/'. WD=%s", fname, getwd()))
  hit[1]
}

# Ler dados (com checagem de colunas essenciais)
path <- find_file("california.csv")
df <- read.csv(path, stringsAsFactors = FALSE)

required <- c("longitude","latitude","housing_median_age","total_rooms","total_bedrooms",
              "population","households","median_income","median_house_value","ocean_proximity")
miss <- setdiff(required, names(df))
if (length(miss)) stop(sprintf("Colunas faltando no dataset: %s", paste(miss, collapse = ", ")))

df$ocean_proximity <- as.factor(df$ocean_proximity)

# Split 50/50
n <- nrow(df)
idx <- sample(n, n/2)
train <- df[idx, , drop = FALSE]
test  <- df[-idx, , drop = FALSE]

# Imputação simples (mediana do treino) para NAs em total_bedrooms
med_tb <- median(train$total_bedrooms, na.rm = TRUE)
train$total_bedrooms[is.na(train$total_bedrooms)] <- med_tb
test$total_bedrooms[is.na(test$total_bedrooms)]  <- med_tb

# Função RMSE
rmse <- function(y, yhat) sqrt(mean((y - yhat)^2))
y_test <- test$median_house_value

# A) ÁRVORE ÚNICA (baseline)
fit_tree <- tree(median_house_value ~ ., data = train)
pred_tree <- predict(fit_tree, newdata = test)
rmse_tree <- rmse(y_test, pred_tree)

# B) BAGGING (bootstrap + média)
B <- 200  # nº de árvores
preds_bag <- matrix(NA_real_, nrow(test), B)
for (b in 1:B) {
  boot <- train[sample(nrow(train), replace = TRUE), ]
  fit  <- tree(median_house_value ~ ., data = boot)
  preds_bag[, b] <- predict(fit, newdata = test)
}
pred_bag <- rowMeans(preds_bag)
rmse_bag <- rmse(y_test, pred_bag)

# C) BAGGING + SUBESPAÇO (mtry = nº fixo de preditores por árvore)
mtry <- 3
pred_names <- setdiff(names(train), "median_house_value")

preds_sub <- matrix(NA_real_, nrow(test), B)
for (b in 1:B) {
  subp <- sample(pred_names, mtry)
  form <- as.formula(paste("median_house_value ~", paste(subp, collapse = "+")))
  boot <- train[sample(nrow(train), replace = TRUE), c("median_house_value", subp), drop = FALSE]
  fit  <- tree(form, data = boot)
  preds_sub[, b] <- predict(fit, newdata = test)
}
pred_sub <- rowMeans(preds_sub)
rmse_sub <- rmse(y_test, pred_sub)

# Resultado no console + CSV
cat("\n--- RMSE no conjunto de TESTE ---\n")
cat(sprintf("Árvore única .............: %.2f\n", rmse_tree))
cat(sprintf("Bagging ...................: %.2f\n", rmse_bag))
cat(sprintf("Bagging + Subespaço (m=%d): %.2f\n", mtry, rmse_sub))

res <- data.frame(
  Modelo = c("Árvore única", "Bagging", sprintf("Bagging + Subespaço (m=%d)", mtry)),
  RMSE   = c(rmse_tree, rmse_bag, rmse_sub),
  check.names = FALSE
)
write.csv(res, "results/Q2_resultados.csv", row.names = FALSE)
