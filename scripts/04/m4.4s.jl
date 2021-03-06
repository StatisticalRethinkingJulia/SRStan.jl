using StanSample, MCMCChains

df = filter(row -> row[:age] >= 18, 
  CSV.read(joinpath(@__DIR__, "..", "..", "data", "Howell1.csv"), DataFrame))

mean_weight = mean(df[!, :weight])
df[!, :weight_c] = convert(Vector{Float64}, df[!, :weight]) .- mean_weight ;

# Define the Stan language model

m4_4s = "
data {
 int < lower = 1 > N; // Sample size
 vector[N] height; // Predictor
 vector[N] weight; // Outcome
}

parameters {
 real alpha; // Intercept
 real beta; // Slope (regression coefficients)
 real < lower = 0 > sigma; // Error SD
}

model {
 height ~ normal(alpha + weight * beta , sigma);
}

generated quantities {
} 
";

# Define the Stanmodel and set the output format to :mcmcchains.

m_4_4s = SampleModel("m4.4s", m4_4s);

# Input data for cmdstan

m4_4_data = Dict("N" => size(df, 1), "height" => df[!, :height], 
"weight" => df[!, :weight_c]);

# Sample using cmdstan

rc = stan_sample(m_4_4s, data=m4_4_data);

# Describe the draws

if success(rc)
  chn = read_samples(m_4_4s; output_format=:mcmcchains)
  #chn = set_names(chn, Dict("mu" => "μ", "sigma" => "σ"))
  describe(chn)
end
