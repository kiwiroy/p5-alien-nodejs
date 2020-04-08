# -*- mode: perl; -*-
requires 'Alien::Build';
requires 'Mojo::DOM58';
requires 'Sort::Versions';
requires 'URI';

test_requires 'Test2::Suite';

on develop => sub {
    requires 'App::af';
};
