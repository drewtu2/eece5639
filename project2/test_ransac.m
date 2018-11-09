close all;
clear;

num_tests = 1;
show_plot = 1;
ransac_errors = zeros(num_tests, 1);
ransac_times = zeros(num_tests, 1);
straight_errors = zeros(num_tests, 1);
straight_times = zeros(num_tests, 1);

for index=1:num_tests
    [straight_errors(index), ransac_errors(index),...
        straight_times(index), ransac_times(index)] = run(show_plot);
end

figure;
hist_result(straight_errors, ransac_errors, straight_times, ransac_times);

function hist_result(straight_result, ransac_result, straight_times, ransac_times)
    
    %edges = 1:10:200;
    bins = 10;
    subplot (1, 3, 1);
    histogram(straight_result, bins, 'DisplayName', 'Straight Result');
    hold on;
    histogram(ransac_result, bins, 'DisplayName', 'Ransac Result');
    
    legend boxoff
    title("Error in Line Estimation");
    xlabel("Error");
    ylabel("Number of Runs");
    
    
    subplot (1, 3, 2);
    c = categorical({'straight','ransac'});
    straight_mean = mean(straight_result);
    ransac_mean = mean(ransac_result);
    
    averages = [straight_mean ransac_mean]
    bar(c, averages, 'DisplayName', 'Straight Error Average');
    ylabel("Average Error");
    title("Average Error");
    
    subplot(1, 3, 3);
    c = categorical({'straight','ransac'});
    straight_mean = mean(straight_times);
    ransac_mean = mean(ransac_times);
    
    time_averages = [straight_mean ransac_mean]
    bar(c, time_averages, 'DisplayName', 'Average Time');
    ylabel("Average Time");
    title("Average Time to Run Algorithm");
end

function [straight_error, ransac_error, straight_time, ransac_time] = run(should_plot)
    % Ransac Params
    % N - max number of times to attempt to find lines
    N = 5;
    % S - Number of samples to compute initial line
    S = 4;
    % D - Degrees from initial reading to sample from
    D = 1;
    % X - Max distance a reading may be from line to get associated to line
    X = 5;
    % C - Number of points that must lie on a line for it to be taken as a line
    C = 20;


    % Line params
    % y = mx + b
    m = 1;
    b = 1;
    coeff = [m b];
    x = 1:100;

    % truth
    y_truth = polyval(coeff, x);
    % add some noise
    noise = 10 * (rand(1, length(x)) - .5); % All noise will be w/in 5
    
    % 10% of points will be outliers
    num_outliers = length(x) * .05; 
    outlier_max_magnitude = 400;
    % Set some outliers
    for index=1:num_outliers
       rand_index = int32(rand * (length(x) - 1)) + 1; % Pick a random index
       noise(rand_index) = noise(rand_index) + (2 * (rand + .5) * outlier_max_magnitude); % Add up to 200. 
    end
    
    noise(length(x)/2) = 500;

    y_noisy = y_truth + noise;
    points = [x' y_noisy'];

    % RANSAC
    [ransac_coeff, ransac_time] = ransac(points, N, S, D, X, C);
    y_ransac = polyval(ransac_coeff, x);
    ransac_error = calculate_error([x' y_truth'], ransac_coeff);

    % Straight Fit
    tic
    straight_coeff = polyfit(x, y_noisy, 1);
    straight_time = toc;
    y_straight = polyval(straight_coeff, x);
    straight_error = calculate_error([x' y_truth'], straight_coeff);
    
    if should_plot
        plot_data(x, y_truth, y_noisy, y_ransac, ransac_error, y_straight, straight_error)
    end
end

function plot_data(x, y_truth, y_noisy, y_ransac, ransac_error, y_straight, straight_error)
    figure;
    scatter(x, y_truth, 'DisplayName', 'y_{truth}');
    hold on;
    scatter(x, y_noisy, 'DisplayName', 'y_{noisy}');
    hold on;
    plot(x, y_ransac, 'DisplayName', strcat('y_{ransac}, error: ', num2str(ransac_error)));
    hold on;
    plot(x, y_straight, 'DisplayName', strcat('y_{straight}, error: ', num2str(straight_error)));
    legend;
end