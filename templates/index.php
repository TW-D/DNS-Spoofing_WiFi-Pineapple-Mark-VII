<?php

    foreach (glob('*') as &$template) {
        if (strpos($template, $_SERVER['HTTP_HOST']) !== false) {
            include_once($template);
        }
    }

?>