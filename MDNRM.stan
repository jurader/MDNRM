data{
  int<upper=3> K; //number of clesses of responses
  int<lower=1> n_doctor; //number of doctors
  int<lower=1> n_case; //number of cases (problems)
  int<lower=1,upper=K> response[n_doctor,n_case]; //matrix of responses
  int<lower=1,upper=3> types[n_case]; //ground truth of cases 
}


parameters {
  vector[K] beta[n_case]; // difficulty
  matrix[K,K] theta[n_doctor]; // ability
}



model{
  int t;
  vector[K] target_theta;
  
  //prior
  for (i in 1:n_doctor){
    for (j in 1:K){
      for (k in 1:K){
        theta[i,j,k] ~ normal(0,2);
      }
    }
  }
  for (i in 1:n_case){
    beta[i] ~ normal(0,2);
  }
  
  // likelihood
  for (i in 1:n_doctor){
    for (j in 1:n_case){
      t = types[j];
      target_theta = to_vector(theta[i,t]);
      response[i,j] ~ categorical_logit(-beta[j] + target_theta);
    }
  }

}

