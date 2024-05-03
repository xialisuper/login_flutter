// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

const String DB_NAME = 'chat_database.db';
const String USER_TOKEN = 'user_token';
const String USER_NAME = 'user_name';
const String USER_TYPE = 'user_type';
const String USER_AVATAR_PATH = 'user_avatar_path';
const String ADMIN_EMAIL = 'admin_email';

/////////  color //////////

const Color COLOR_SELECTED_BUTTON_BACKGROUND = Color.fromRGBO(179, 229, 224, 1);
const Color COLOR_UNSELECTED_BUTTON_BACKGROUND =
    Color.fromRGBO(179, 229, 224, 0.2);

const Color COLOR_TEXT_PRIMARY = Color.fromRGBO(33, 33, 33, 1);
const Color COLOR_TEXT_SECONDARY = Color.fromRGBO(179, 179, 179, 1);

///////////  toast  //////////

const int TOAST_DURATION_SECONDS = 2;
const String TOAST_SUCCESS_MESSAGE = 'Success';
const String TOAST_FAILURE_MESSAGE = 'Failure';
const String TOAST_INVALID_USERNAME =
    'Please enter a valid user name, length is at least 6';

const String TOAST_INVALID_PASSWORD =
    'Please enter a valid password, length is at least 8';

const String TOAST_INVALID_EMAIL = 'Please enter a valid email address';