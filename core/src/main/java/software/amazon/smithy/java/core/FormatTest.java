/*
 * Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 * SPDX-License-Identifier: Apache-2.0
 */

package software.amazon.smithy.java.core;

import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.ArrayList;

public final class FormatTest {
        private final String name;
    private final int value;

    public FormatTest(String name,int value) {
            this.name = name;
                this.value = value;
    }

    public String getName() { return name; }
        public int getValue(){return value;}
}
