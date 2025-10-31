# Q2 - California Housing — árvore, bagging e subespaço (simples)

set.seed(42)
library(tree)

# 1) Ler dados
df <- read.csv("data/california.csv", stringsAsFactors = FALSE)
df$ocean_proximity <- as.factor(df$ocean_proximity)

# 2) Split 50/50
n <- nrow(df)
idx <- sample(n, n/2)
train <- df[idx, ]
test  <- df[-idx, ]

# 3) Imputação simples (mediana do treino) para NAs em total_bedrooms
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
  boot <- train[sample(nrow(train), replace = TRUE), c("median_house_value", subp)]
  fit  <- tree(form, data = boot)
  preds_sub[, b] <- predict(fit, newdata = test)
}
pred_sub <- rowMeans(preds_sub)
rmse_sub <- rmse(y_test, pred_sub)

# Resultado
cat("\n--- RMSE no conjunto de TESTE ---\n")
cat(sprintf("Árvore única .............: %.2f\n", rmse_tree))
cat(sprintf("Bagging ...................: %.2f\n", rmse_bag))
cat(sprintf("Bagging + Subespaço (m=%d): %.2f\n", mtry, rmse_sub))
