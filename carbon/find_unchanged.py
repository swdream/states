#!/usr/bin/env python
# -*- encoding: utf-8
# Use of this is governed by a license that can be found in doc/license.rst.

"""
A script for finding (and/or deleting) all old files/directories under
given path.  A directory is considered old if ALL files it contains have not
changed since last N days, N passed by user.
"""

__author__ = 'Viet Hung Nguyen'
__maintainer__ = 'Viet Hung Nguyen'
__email__ = 'hvnsweeting@gmail.com'

import os
import logging
import shutil
from datetime import datetime, timedelta

import pysc


log = logging.getLogger()


def _contains_all_old_files(dirpath, days):
    log.debug('Checking directory %s', dirpath)
    for root, dirs, files in os.walk(dirpath):
        for f in files:
            path = os.path.join(root, f)
            if os.path.isfile(path) or os.path.isdir(path):
                if _is_new(path, days):
                    log.debug(('File %s is modified since last %d days, '
                              'skip containing dir'), path, days)
                    return False
    return True


def _is_new(fpath, days):
    '''
    file is last modified since ``days`` days ago
    '''
    return (datetime.now() - datetime.fromtimestamp(os.stat(fpath).st_mtime) <
            timedelta(days))


def _delete_or_print(fpath, delete=False):
    if delete:
        shutil.rmtree(fpath, ignore_errors=True)
    else:
        print fpath


def find_unchanged(rootdirs, days, delete):
    for rootdir in rootdirs:
        log.info('Checking old directories under %s', rootdir)
        for adir in os.listdir(rootdir):
            fpath = os.path.join(os.path.abspath(rootdir), adir)
            if os.path.isdir(fpath):
                if _contains_all_old_files(fpath, days):
                    _delete_or_print(fpath, delete)
            else:
                if not _is_new(fpath, days):
                    _delete_or_print(fpath, delete)


class FindUnchanged(pysc.Application):
    logger = log

    def get_argument_parser(self):
        argp = super(FindUnchanged, self).get_argument_parser()
        argp.add_argument('--days', help=('number of days that file should '
                          'be considered old'), default=10, metavar='DAYS',
                          type=int)
        argp.add_argument('--delete', help='delete found directory',
                          action='store_true')
        argp.add_argument('rootdirs', nargs='+',
                          help='root dir(s) to find old files/directories')
        return argp

    def main(self):
        find_unchanged(self.config['rootdirs'], self.config['days'],
                       self.config['delete'])

if __name__ == '__main__':
    FindUnchanged().run()
