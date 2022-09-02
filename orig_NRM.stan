data{
  int<lower=2, upper=4> K; //  number of categories
  int<lower=0> n_doctor; //  number of individuals
  int<lower=0> n_case; //  number of items
  int<lower=1,upper=K> response[n_doctor,n_case]; //array of responses
}


parameters {
  vector[K] zeta[n_case]; // intercept
  vector[K] lambda[n_case]; // slope
  vector[n_doctor] theta; // latent trait
}


transformed parameters {
  vector[K] zetan[n_case]; // centered intercept
  vector[K] lambdan[n_case]; // centered slope
  
  for (k in 1:n_case) {
    for (l in 1:K) {
      zetan[k,l] = zeta[k,l]-mean(zeta[k]);
      lambdan[k,l] = lambda[k,l]-mean(lambda[k]);
    }
  }
}


model{
  theta ~ normal(0,1);
  
  for (i in 1: n_case){
    zeta[i] ~ normal(0,2);
    lambda[i] ~ normal(0,2);
  }
  
  for (i in 1:n_doctor){
    for (j in 1:n_case){
      response[i,j] ~ categorical_logit(zetan[j]+lambdan[j]*theta[i]);
    }
  }
}


