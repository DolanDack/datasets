# Combining SAE, DML and SVGP for Small-Area Spending Research

## Purpose

The current notebook uses three complementary modelling components:

- Bayesian small-area estimation (SAE) for uncertainty-aware local spending profiles.
- Double/debiased machine learning (DML) for interpretable conditional income effects.
- Sparse variational Gaussian processes (SVGP) for nonlinear multi-output prediction.

At present, these models use the same LAD-level data and the same spending outcome construction, but they are not mechanically connected. A next research step is to combine them in a principled statistical framework.

## Current Roles

### Bayesian SAE

Bayesian SAE answers:

```text
What is the expected spending profile of each local area, with uncertainty?
```

It estimates spending intensity and transformed spending composition while partially pooling LADs through regional random effects.

### DML Causality

DML answers:

```text
How is median income conditionally associated with spending outcomes,
under an explicit adjustment set?
```

It residualises both the spending outcome and the treatment using observed confounders, then estimates the remaining treatment-outcome relationship.

### SVGP Prediction

SVGP answers:

```text
How accurately can socioeconomic context predict area-level spending intensity
and budget composition?
```

It learns a flexible nonlinear mapping from LAD socioeconomic features to valid spending-share outputs.

## Option 1: Bayesian SAE With a GP Mean Function

The simplest combination is to replace the linear SAE mean function with a GP component:

$$
y_{ij} \sim \mathcal{N}(\mu_{ij}, \sigma_j^2)
$$

$$
\mu_{ij} = f_j(\mathbf{x}_i) + u_{r[i]j}
$$

$$
u_{rj} \sim \mathcal{N}(0, \tau_j^2)
$$

$$
f_j(\cdot) \sim \mathcal{GP}(0, k_j(\cdot,\cdot))
$$

This combines:

- nonlinear prediction from the GP;
- regional partial pooling from SAE;
- posterior uncertainty from the Bayesian hierarchy.

This is a strong predictive model, but it is not automatically causal.

## Option 2: DML With GP Nuisance Functions

DML requires two nuisance functions:

$$
m(\mathbf{W}_i) = \mathbb{E}[Y_i \mid \mathbf{W}_i]
$$

$$
g(\mathbf{W}_i) = \mathbb{E}[T_i \mid \mathbf{W}_i]
$$

where \(T_i\) is the treatment, such as log median income, and \(\mathbf{W}_i\) is the adjustment set.

Instead of estimating these nuisance functions with random forests, we can estimate them with GP or SVGP models:

$$
\tilde{Y}_i = Y_i - \hat{m}(\mathbf{W}_i)
$$

$$
\tilde{T}_i = T_i - \hat{g}(\mathbf{W}_i)
$$

$$
\tilde{Y}_i = \theta \tilde{T}_i + \varepsilon_i
$$

This combines:

- DML's causal identification structure;
- GP flexibility for nonlinear adjustment;
- orthogonalisation to reduce bias from nuisance-model error.

This is a practical next step if the goal is causal estimation.

## Option 3: Bayesian Hierarchical Causal GP

A more integrated journal-level model combines treatment effects, nonlinear residual structure and regional pooling:

$$
y_{ij} \sim \mathcal{N}(\mu_{ij}, \sigma_j^2)
$$

$$
\mu_{ij}
=
\alpha_j
+ \theta_j T_i
+ f_j(\mathbf{W}_i)
+ u_{r[i]j}
$$

$$
u_{rj} \sim \mathcal{N}(0, \tau_j^2)
$$

$$
f_j(\cdot) \sim \mathcal{GP}(0, k_j(\cdot,\cdot))
$$

where:

- \(y_{ij}\) is the transformed spending outcome for LAD \(i\) and outcome \(j\);
- \(T_i\) is the treatment, for example log median income;
- \(\mathbf{W}_i\) is the confounder set;
- \(\theta_j\) is the income effect for spending outcome \(j\);
- \(f_j(\mathbf{W}_i)\) captures nonlinear socioeconomic structure;
- \(u_{r[i]j}\) provides regional SAE-style partial pooling.

This model combines all three ideas:

- Bayesian SAE: through regional random effects and posterior uncertainty;
- causality: through an explicit treatment term and adjustment set;
- GP prediction: through nonlinear functions of the control variables.

## Option 4: LMC Extension for Shared Spending Factors

For multi-output spending outcomes, the GP component can use a linear model of coregionalisation (LMC):

$$
f_j(\mathbf{x})
=
\sum_{\ell=1}^{L}
w_{j\ell} g_{\ell}(\mathbf{x})
$$

$$
g_{\ell}(\cdot) \sim \mathcal{GP}(0, k_{\ell}(\cdot,\cdot))
$$

The latent functions \(g_{\ell}\) can be interpreted as shared spending factors, such as:

- essentials;
- housing and mobility;
- discretionary consumption.

This may improve prediction when spending categories share common structure, but it can overfit if the number of LADs is small.

## Recommended Research Path

### Step 1: Stabilise the current outputs

- Keep the current Bayesian SAE, DML and SVGP results as independent baselines.
- Use grouped validation, especially region holdout and target-profile holdout.
- Continue reporting valid spending composition via ALR/inverse-ALR.

### Step 2: Use DML to define causal structure

- Select one treatment at a time, starting with log median income.
- Define the adjustment set using a DAG.
- Compare total-effect and direct-effect specifications.

### Step 3: Build a Bayesian hierarchical causal model

Start with:

$$
\mu_{ij}
=
\alpha_j
+ \theta_j T_i
+ \mathbf{W}_i^\top \boldsymbol{\beta}_j
+ u_{r[i]j}
$$

Then replace the linear control function with a GP:

$$
\mu_{ij}
=
\alpha_j
+ \theta_j T_i
+ f_j(\mathbf{W}_i)
+ u_{r[i]j}
$$

### Step 4: Compare against SVGP prediction

The combined model should be compared against:

- Bayesian SAE without GP;
- DML with non-GP nuisance models;
- separate-output SVGP;
- LMC-SVGP.

## Interpretation Caveat

Combining the methods does not make causality automatic. The causal interpretation of \(\theta_j\) still depends on whether the adjustment set \(\mathbf{W}_i\) blocks confounding paths without controlling for mediators or colliders.

The correct framing is:

```text
Under the stated causal adjustment assumptions, the combined model estimates
income effects on area-level spending outcomes while accounting for nonlinear
socioeconomic structure, regional partial pooling and posterior uncertainty.
```

