# APS Modelagem Preditiva

Projeto analítico que aplica técnicas de modelagem preditiva para compreender padrões e antecipar comportamentos a partir de dados reais.
O estudo envolve a construção, comparação e interpretação de modelos de **classificação** e **regressão**, transformando dados em decisões com base estatística.

---

## Estrutura do Projeto

```
modelagem_preditiva/
│
├── code/                           # scripts de análise e modelagem (Q1, Q2, Q3, Q4, A1, A2)
├── data/                           # conjuntos de dados (não versionados)
├── docs/                           # enunciado da APS e relatório final
├── images/                         # gráficos (gerados automaticamente)
├── results/                        # tabelas de resultados (geradas automaticamente)
├── .gitignore                      # arquivos/pastas ignorados no versionamento
├── main.R                          # orquestra a execução dos exercícios em code/
├── modelagem_preditiva.Rproj       # projeto RStudio
└── README.md                       # visão geral do projeto
```

---

## Objetivos

* Desenvolver modelos preditivos em **cenários reais** (churn e mercado automotivo).
* Comparar algoritmos via **Acurácia**, **AUC** e **RMSE**.
* Discutir **viés vs. variância** e **aleatorização** (bagging/Random Forest).
* Gerar **insights interpretáveis** para decisão.

---

## Pasta `data/`

A pasta `data/` contém os conjuntos de dados **necessários para rodar os scripts**.
Os arquivos **não são versionados no GitHub**; coloque-os localmente antes da execução.

| Arquivo           | Uso                                    |
| ----------------- | -------------------------------------- |
| `Q1_training.csv` | Treinamento da **Q1** (classificação). |
| `Q1_test.csv`     | Teste da **Q1** (cálculo de AUC).      |
| `churn.csv`       | Base de **churn** (A1).                |
| `used_cars.csv`   | Base de **carros** usados (A2).        |
| `california.csv`  | **California Housing** (Q2–Q4).        |

> Se os arquivos não estiverem em `data/`, os scripts tentam caminhos alternativos (`./`, `../data/`) e mostram uma **mensagem clara** se não encontrarem.

---

## Execução

O projeto pode ser executado no **RStudio** ou **VS Code** (com R).

### 1) Clonar o repositório

```bash
git clone https://github.com/gustavoribolla/modelagem_preditiva.git
cd modelagem_preditiva
```

### 2) Abrir no RStudio (ou VS Code)

### 3) Instalar bibliotecas

```r
install.packages(c("tree","ranger","pROC","class"))
# CatBoost (os scripts funcionam sem ele; se não estiver instalado, é ignorado)
# install.packages("catboost", repos = c("https://cloud.r-project.org",
#                                        "https://catboost-r.s3.eu-central-1.amazonaws.com/cran/latest/"))
```

### 4) Colocar os dados em `data/`

### 5) Rodar

* Tudo de uma vez:

```r
source("main.R")
```

* Ou por exercício (ex.: Q2):

```r
source("code/Q2.R")
```

**Saídas automáticas:**

* Figuras em `images/<exercicio>/...` (ex.: `images/Q4/Q4_OOB_vs_Test.png`).
* Tabelas em `results/` (ex.: `results/A1_resultados.csv`, `results/Q4_oob_vs_test.csv`).

> Os scripts **criam as pastas** `images/<exercicio>` e `results` se não existirem.

---

## Relatório

📄 Link para o relatório completo (teoria, resultados e discussão):
[Acesse aqui](https://alinsperedu-my.sharepoint.com/:w:/g/personal/gustavocr2_al_insper_edu_br/ES2YJpYvL7BOj9zKbNkkS_MBnUZtruXpNpnpJ3LVVA7_EA?e=1Rf1pi)

---

## Modelos Utilizados

* Regressão Logística
* Árvores de Classificação e Regressão
* Bagging e Random Forests
* k-NN (k-Nearest Neighbors)
* CatBoost *(opcional nos scripts)*

---

## Aplicações

* **Churn (A1):** previsão de cancelamento de clientes bancários.
* **Preço de automóveis (A2):** estimativa de valor de mercado (Mercedes).

---

## Conceitos-Chave

* **Viés × Variância**
* **Bootstrap/Bagging**
* **Aleatorização de splits** (Random Forest)
* **Erro Out-of-Bag (OOB)**
* **ROC/AUC** e **RMSE**

---

## Autor

**Gustavo Colombi Ribolla**
Estudante de Ciência da Computação - Insper
🔗 [linkedin.com/in/gustavoribolla](https://linkedin.com/in/gustavoribolla)