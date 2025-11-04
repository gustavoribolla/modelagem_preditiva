# Q1 - Regressão Logística vs Árvore de Classificação (AUC em teste)

set.seed(42)
suppressPackageStartupMessages({
  library(tree)
  library(pROC)
})

dir.create("images", showWarnings = FALSE, recursive = TRUE)

# 1) Leitura e preparação
train <- read.csv("data/Q1_training.csv", stringsAsFactors = FALSE)
test  <- read.csv("data/Q1_test.csv",    stringsAsFactors = FALSE)

# y binária como fator "0"/"1" (classe positiva = "1") e para pROC (0/1)
train$y <- factor(train$y, levels = c(0, 1), labels = c("0", "1"))
test$y  <- factor(test$y,  levels = levels(train$y))
y_test01 <- as.integer(test$y == "1")

# 2) Modelos baseline
## 2.1 Logística
m_log <- glm(y ~ ., data = train, family = binomial())
p_log <- predict(m_log, newdata = test, type = "response")
roc_log <- roc(y_test01, p_log, quiet = TRUE); auc_log <- as.numeric(auc(roc_log))

## 2.2 Árvore de Classificação
m_tree <- tree(y ~ ., data = train)
p_tree_mat <- predict(m_tree, newdata = test, type = "vector")
p_tree <- if (is.matrix(p_tree_mat)) p_tree_mat[, "1"] else p_tree_mat
roc_tree <- roc(y_test01, p_tree, quiet = TRUE); auc_tree <- as.numeric(auc(roc_tree))

cat(sprintf("\nAUC (baseline)\n  Logística: %.4f\n  Árvore   : %.4f\n", auc_log, auc_tree))

# ROC baseline
png("images/Q1/Q1_ROC_baseline.png", width = 1100, height = 750, res = 120)
plot(roc_log,  main = "Q1 — ROC (Baseline): Logística (linha cheia) vs Árvore (tracejada)")
plot(roc_tree, add = TRUE, lty = 2)
legend("bottomright",
       legend = c(paste0("Logística AUC = ", round(auc_log,3)),
                  paste0("Árvore AUC    = ", round(auc_tree,3))),
       lty = c(1,2), bty = "n")
dev.off()

# 3) Modificando a logística (termos quadráticos + interação)
m_log2 <- glm(y ~ poly(x1, 2, raw = TRUE) + poly(x2, 2, raw = TRUE) + x1:x2,
              data = train, family = binomial())
p_log2 <- predict(m_log2, newdata = test, type = "response")
roc_log2 <- roc(y_test01, p_log2, quiet = TRUE); auc_log2 <- as.numeric(auc(roc_log2))
cat(sprintf("\nAUC (logística aprimorada)\n  Logística + quad.+interação: %.4f\n", auc_log2))

# ROC comparativa (árvore x logísticas)
png("images/Q1/Q1_ROC_comparison.png", width = 1100, height = 750, res = 120)
plot(roc_tree,  main = "Q1 — ROC: Árvore (cheia), Logística (tracejada), Logística Aprimorada (pontilhada)")
plot(roc_log,  add = TRUE, lty = 2)
plot(roc_log2, add = TRUE, lty = 3)
legend("bottomright",
       legend = c(paste0("Árvore                 AUC = ", round(auc_tree,3)),
                  paste0("Logística (baseline)   AUC = ", round(auc_log,3)),
                  paste0("Logística (aprimorada) AUC = ", round(auc_log2,3))),
       lty = c(1,2,3), bty = "n")
dev.off()